/* ═══════════════════════════════════════════════════════════════════════════
   Hyundai DMS — Dashboard JavaScript
   ═══════════════════════════════════════════════════════════════════════════ */

const API = '';  // Same origin
const charts = {};

// ─── Chart.js Global Defaults ────────────────────────────────────────────────
Chart.defaults.color = '#94a3b8';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';
Chart.defaults.font.family = 'Inter, sans-serif';

const COLORS = [
    '#00AAD2', '#0073C5', '#002C5F', '#22c55e', '#eab308',
    '#ef4444', '#a855f7', '#f97316', '#06b6d4', '#ec4899',
    '#6366f1', '#14b8a6'
];

// ─── Helpers ─────────────────────────────────────────────────────────────────
function fmt(n) {
    if (n === null || n === undefined) return '—';
    if (n >= 10000000) return '₹' + (n / 10000000).toFixed(2) + ' Cr';
    if (n >= 100000) return '₹' + (n / 100000).toFixed(2) + ' L';
    return '₹' + Number(n).toLocaleString('en-IN');
}
function fmtN(n) { return n !== null && n !== undefined ? Number(n).toLocaleString('en-IN') : '—'; }

function showSection(name) {
    document.querySelectorAll('.section-content').forEach(s => s.classList.add('hidden'));
    document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('section-' + name).classList.remove('hidden');
    document.getElementById('nav-' + name).classList.add('active');
}

function showLoader(el) {
    el.innerHTML = '<div class="flex items-center justify-center h-40"><div class="spinner"></div></div>';
}

function destroyChart(id) {
    if (charts[id]) { charts[id].destroy(); delete charts[id]; }
}

function statusBadge(status) {
    if (!status) return '';
    const cls = {
        'Converted': 'badge-converted', 'New': 'badge-new', 'Lost': 'badge-lost',
        'Follow-up': 'badge-followup', 'Delivered': 'badge-delivered',
        'In-Transit': 'badge-transit', 'Booked': 'badge-booked',
        'Completed': 'badge-completed', 'Pending': 'badge-pending'
    }[status] || 'badge-new';
    return `<span class="badge ${cls}">${status}</span>`;
}

// ─── API Fetch ───────────────────────────────────────────────────────────────
async function apiFetch(url) {
    try {
        const res = await fetch(API + url);
        const json = await res.json();
        if (json.status === 'success') return json.data;
        console.error('API error:', json.error);
        return null;
    } catch (e) {
        console.error('Fetch error:', e);
        return null;
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
async function loadDashboard() {
    const [summary, annual] = await Promise.all([
        apiFetch('/api/dashboard/summary'),
        apiFetch('/api/reports/annual-sales?year=2025')
    ]);

    // KPI Cards
    if (summary) {
        const kpis = [
            { label: 'Total Sales', value: fmtN(summary.total_sales), icon: '🚗' },
            { label: 'Revenue', value: fmt(summary.total_revenue), icon: '💰' },
            { label: 'Enquiries', value: fmtN(summary.total_enquiries), icon: '📋' },
            { label: 'Converted', value: fmtN(summary.converted_enquiries), icon: '✅' },
            { label: 'Conv. Rate', value: summary.conversion_rate + '%', icon: '📊' },
            { label: 'Branches', value: fmtN(summary.active_branches), icon: '🏢' },
        ];
        document.getElementById('kpi-cards').innerHTML = kpis.map((k, i) =>
            `<div class="kpi-card animate-in" style="animation-delay:${i * 80}ms">
                <div class="text-2xl mb-2">${k.icon}</div>
                <div class="kpi-value">${k.value}</div>
                <div class="kpi-label">${k.label}</div>
            </div>`
        ).join('');
    }

    // Monthly Sales Chart
    if (annual && annual.monthly) {
        destroyChart('dashMonthlySalesChart');
        const ctx = document.getElementById('dashMonthlySalesChart').getContext('2d');
        charts['dashMonthlySalesChart'] = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: annual.monthly.map(m => m.month_name?.substring(0, 3)),
                datasets: [{
                    label: 'Units Sold',
                    data: annual.monthly.map(m => m.units_sold),
                    backgroundColor: 'rgba(0,170,210,0.7)',
                    borderColor: '#00AAD2',
                    borderWidth: 1,
                    borderRadius: 6,
                    barPercentage: 0.6
                }, {
                    label: 'Revenue (₹ Lakhs)',
                    data: annual.monthly.map(m => m.revenue / 100000),
                    type: 'line',
                    borderColor: '#22c55e',
                    backgroundColor: 'rgba(34,197,94,0.1)',
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#22c55e',
                    pointRadius: 4,
                    yAxisID: 'y1'
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                scales: {
                    y: { beginAtZero: true, title: { display: true, text: 'Units' } },
                    y1: { position: 'right', beginAtZero: true, title: { display: true, text: '₹ Lakhs' }, grid: { drawOnChartArea: false } }
                },
                plugins: { legend: { position: 'top' } }
            }
        });
    }

    // Model Chart
    if (annual && annual.by_model) {
        destroyChart('dashModelChart');
        const ctx = document.getElementById('dashModelChart').getContext('2d');
        charts['dashModelChart'] = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: annual.by_model.map(m => m.model_name),
                datasets: [{
                    data: annual.by_model.map(m => m.units_sold),
                    backgroundColor: COLORS.slice(0, annual.by_model.length),
                    borderWidth: 0,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                cutout: '60%',
                plugins: { legend: { position: 'right', labels: { padding: 12, usePointStyle: true, pointStyleWidth: 10 } } }
            }
        });
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANNUAL SALES REPORT
// ═══════════════════════════════════════════════════════════════════════════════
async function loadAnnualReport() {
    const data = await apiFetch('/api/reports/annual-sales?year=2025');
    if (!data) return;

    // Bar Chart — monthly
    if (data.monthly) {
        destroyChart('annualBarChart');
        const ctx = document.getElementById('annualBarChart').getContext('2d');
        charts['annualBarChart'] = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.monthly.map(m => m.month_name),
                datasets: [{
                    label: 'Units Sold',
                    data: data.monthly.map(m => m.units_sold),
                    backgroundColor: data.monthly.map((_, i) => COLORS[i % COLORS.length]),
                    borderRadius: 8,
                    barPercentage: 0.65
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
            }
        });
    }

    // Colour Pie
    if (data.by_colour) {
        destroyChart('colourPieChart');
        const ctx = document.getElementById('colourPieChart').getContext('2d');
        const bgCols = data.by_colour.map(c => c.hex_code || '#888');
        charts['colourPieChart'] = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: data.by_colour.map(c => c.colour_name),
                datasets: [{ data: data.by_colour.map(c => c.units_sold), backgroundColor: bgCols, borderWidth: 2, borderColor: '#0a0f1a' }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: { legend: { position: 'right', labels: { padding: 10, usePointStyle: true, pointStyleWidth: 10 } } }
            }
        });
    }

    // Branch Pie
    if (data.by_branch) {
        destroyChart('branchPieChart');
        const ctx = document.getElementById('branchPieChart').getContext('2d');
        charts['branchPieChart'] = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: data.by_branch.map(b => b.branch_name.replace(/Hyundai — |Hyundai – /g, '')),
                datasets: [{ data: data.by_branch.map(b => b.revenue), backgroundColor: COLORS, borderWidth: 0, hoverOffset: 10 }]
            },
            options: {
                responsive: true, maintainAspectRatio: false, cutout: '55%',
                plugins: { legend: { position: 'right', labels: { padding: 8, usePointStyle: true, pointStyleWidth: 10, font: { size: 11 } } } }
            }
        });

        // Table
        const tbody = document.querySelector('#branchTable tbody');
        tbody.innerHTML = data.by_branch.map(b =>
            `<tr>
                <td class="py-2 font-medium">${b.branch_name}</td>
                <td class="py-2 text-gray-400">${b.city}</td>
                <td class="py-2 text-right">${fmtN(b.units_sold)}</td>
                <td class="py-2 text-right text-hyundai-blue font-semibold">${fmt(b.revenue)}</td>
                <td class="py-2 text-right">${b.pct_contribution}%</td>
            </tr>`
        ).join('');
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEAD CONVERSION
// ═══════════════════════════════════════════════════════════════════════════════
async function loadLeadConversion() {
    const data = await apiFetch('/api/reports/lead-conversion');
    if (!data) return;

    destroyChart('leadConversionChart');
    const ctx = document.getElementById('leadConversionChart').getContext('2d');
    charts['leadConversionChart'] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.map(d => d.branch_name.replace(/Hyundai — |Hyundai – /g, '')),
            datasets: [
                { label: 'Converted', data: data.map(d => d.converted), backgroundColor: 'rgba(34,197,94,0.7)', borderRadius: 4, stack: 'a' },
                { label: 'Pipeline', data: data.map(d => d.in_pipeline), backgroundColor: 'rgba(59,130,246,0.7)', borderRadius: 4, stack: 'a' },
                { label: 'Lost', data: data.map(d => d.lost), backgroundColor: 'rgba(239,68,68,0.7)', borderRadius: 4, stack: 'a' }
            ]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            scales: { x: { stacked: true }, y: { stacked: true, beginAtZero: true } },
            plugins: { legend: { position: 'top' } }
        }
    });

    const tbody = document.querySelector('#leadTable tbody');
    tbody.innerHTML = data.map(d =>
        `<tr>
            <td class="py-2 font-medium">${d.branch_name}</td>
            <td class="py-2 text-gray-400">${d.dealer_name}</td>
            <td class="py-2 text-gray-400">${d.branch_city}</td>
            <td class="py-2 text-right">${d.total_enquiries}</td>
            <td class="py-2 text-right text-green-400 font-semibold">${d.converted}</td>
            <td class="py-2 text-right text-red-400">${d.lost}</td>
            <td class="py-2 text-right text-blue-400">${d.in_pipeline}</td>
            <td class="py-2 text-right font-bold text-hyundai-blue">${d.conversion_rate}%</td>
        </tr>`
    ).join('');
}

// ═══════════════════════════════════════════════════════════════════════════════
// REGIONAL PERFORMANCE
// ═══════════════════════════════════════════════════════════════════════════════
async function loadRegionalPerformance() {
    const data = await apiFetch('/api/reports/regional-performance');
    if (!data) return;

    const tbody = document.querySelector('#regionalTable tbody');
    tbody.innerHTML = data.map(r =>
        `<tr>
            <td class="py-2 px-2 font-medium border-r border-white/5">
                <div class="text-[10px] text-gray-500 uppercase">${r.model_name}</div>
                <div class="text-xs">${r.variant_name}</div>
            </td>
            
            <td class="py-2 px-1 text-right">${r.chennai_units || 0}</td>
            <td class="py-2 px-1 text-right text-gray-400 border-r border-white/5">${fmt(r.chennai_revenue)}</td>
            
            <td class="py-2 px-1 text-right">${r.bengaluru_units || 0}</td>
            <td class="py-2 px-1 text-right text-gray-400 border-r border-white/5">${fmt(r.bengaluru_revenue)}</td>
            
            <td class="py-2 px-1 text-right">${r.hyderabad_units || 0}</td>
            <td class="py-2 px-1 text-right text-gray-400 border-r border-white/5">${fmt(r.hyderabad_revenue)}</td>
            
            <td class="py-2 px-1 text-right">${r.delhi_units || 0}</td>
            <td class="py-2 px-1 text-right text-gray-400 border-r border-white/5">${fmt(r.delhi_revenue)}</td>
            
            <td class="py-2 px-1 text-right">${r.mumbai_units || 0}</td>
            <td class="py-2 px-1 text-right text-gray-400 border-r border-white/5">${fmt(r.mumbai_revenue)}</td>
            
            <td class="py-2 px-1 text-right bg-hyundai-blue/5 font-bold">${r.total_units}</td>
            <td class="py-2 px-1 text-right bg-hyundai-blue/10 font-extrabold text-hyundai-blue">${fmt(r.total_revenue)}</td>
        </tr>`
    ).join('');
}

// ═══════════════════════════════════════════════════════════════════════════════
// INVOICE LOOKUP
// ═══════════════════════════════════════════════════════════════════════════════
async function loadCustomers() {
    const data = await apiFetch('/api/customers');
    if (!data) return;
    const sel = document.getElementById('customerSelect');
    data.forEach(c => {
        const opt = document.createElement('option');
        opt.value = c.customer_id;
        opt.textContent = `${c.name} — ${c.city} (${c.phone})`;
        sel.appendChild(opt);
    });
}

async function loadInvoice() {
    const cid = document.getElementById('customerSelect').value;
    if (!cid) return;
    const el = document.getElementById('invoiceContent');
    showLoader(el);

    const data = await apiFetch(`/api/reports/invoice/${cid}`);
    if (!data || data.length === 0) {
        el.innerHTML = '<div class="card p-8 text-center text-gray-500">No records found for this customer.</div>';
        return;
    }

    // Group by enquiry
    const grouped = {};
    data.forEach(r => {
        const key = r.enquiry_id;
        if (!grouped[key]) grouped[key] = { info: r, payments: [] };
        if (r.payment_date) grouped[key].payments.push(r);
    });

    let html = '';
    // Customer header
    const first = data[0];
    html += `<div class="card p-6 mb-6 animate-in">
        <div class="grid md:grid-cols-3 gap-4">
            <div><span class="text-xs text-gray-500">Customer</span><p class="font-bold text-lg">${first.customer_name}</p></div>
            <div><span class="text-xs text-gray-500">Phone</span><p class="font-medium">${first.customer_phone || '—'}</p></div>
            <div><span class="text-xs text-gray-500">Email</span><p class="font-medium">${first.customer_email || '—'}</p></div>
        </div>
    </div>`;

    // Each enquiry card
    Object.values(grouped).forEach((g, idx) => {
        const r = g.info;
        html += `<div class="invoice-card animate-in" style="animation-delay:${idx * 100}ms">
            <div class="flex justify-between items-start mb-4">
                <div>
                    <p class="text-xs text-gray-500 mb-1">Enquiry #${r.enquiry_id} · ${r.enquiry_date || ''}</p>
                    <p class="font-bold text-lg">${r.enquired_model || ''} ${r.enquired_variant || ''}</p>
                    <p class="text-sm text-gray-400">${r.car_type || ''} · ${r.preferred_colour || ''}</p>
                </div>
                <div class="text-right">
                    ${statusBadge(r.enquiry_status)}
                    <p class="text-xs text-gray-500 mt-1">${r.branch_name || ''}</p>
                    <p class="text-xs text-gray-500">${r.sales_executive || ''}</p>
                </div>
            </div>`;

        if (r.sale_id) {
            html += `<div class="border-t border-white/5 pt-4 mt-4">
                <p class="text-xs text-gray-500 mb-3">SALE #${r.sale_id} · ${r.sale_date || ''}</p>
                <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-3 text-sm mb-4">
                    <div><span class="text-gray-500">Model</span><p class="font-medium">${r.sold_model} ${r.sold_variant}</p></div>
                    <div><span class="text-gray-500">Colour</span><p class="font-medium">${r.delivered_colour || '—'}</p></div>
                    <div><span class="text-gray-500">VIN</span><p class="font-mono text-xs">${r.vin_number || '—'}</p></div>
                    <div><span class="text-gray-500">Delivery</span><p>${statusBadge(r.delivery_status)} <span class="text-xs ml-1">${r.delivery_date || ''}</span></p></div>
                </div>
                <div class="bg-black/20 rounded-xl p-4 mb-4">
                    <p class="text-xs text-gray-500 mb-3 uppercase tracking-wider font-semibold">Tax Invoice Breakdown</p>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
                        <div><span class="text-gray-500">Ex-Showroom</span><p class="font-bold text-hyundai-blue">${fmt(r.sale_ex_showroom)}</p></div>
                        <div><span class="text-gray-500">CGST (${r.gst_percent / 2}%)</span><p>${fmt(r.cgst_amount)}</p></div>
                        <div><span class="text-gray-500">SGST (${r.gst_percent / 2}%)</span><p>${fmt(r.sgst_amount)}</p></div>
                        <div><span class="text-gray-500">Total GST</span><p>${fmt(r.total_gst)}</p></div>
                        <div><span class="text-gray-500">Road Tax</span><p>${fmt(r.road_tax)}</p></div>
                        <div><span class="text-gray-500">Insurance</span><p>${fmt(r.insurance)}</p></div>
                        <div><span class="text-gray-500">Accessories</span><p>${fmt(r.accessories)}</p></div>
                        <div><span class="text-gray-500">On-Road Price</span><p class="font-bold text-xl text-white">${fmt(r.total_on_road)}</p></div>
                    </div>
                </div>`;

            if (g.payments.length > 0) {
                html += `<div class="bg-black/20 rounded-xl p-4">
                    <p class="text-xs text-gray-500 mb-3 uppercase tracking-wider font-semibold">Payment Ledger</p>
                    <table class="w-full text-sm"><thead><tr class="text-gray-500 border-b border-white/10">
                        <th class="py-1 text-left">Date</th><th class="py-1 text-right">Amount</th>
                        <th class="py-1 text-left">Mode</th><th class="py-1 text-left">Reference</th>
                        <th class="py-1 text-left">Status</th><th class="py-1 text-right">Running Total</th>
                    </tr></thead><tbody>`;
                g.payments.forEach(p => {
                    html += `<tr>
                        <td class="py-1">${p.payment_date || ''}</td>
                        <td class="py-1 text-right font-medium">${fmt(p.payment_amount)}</td>
                        <td class="py-1">${p.payment_mode || ''}</td>
                        <td class="py-1 font-mono text-xs">${p.reference_no || ''}</td>
                        <td class="py-1">${statusBadge(p.payment_status)}</td>
                        <td class="py-1 text-right">${fmt(p.running_total)}</td>
                    </tr>`;
                });
                const last = g.payments[g.payments.length - 1];
                html += `</tbody></table>
                    <div class="mt-3 pt-3 border-t border-white/10 flex justify-between text-sm">
                        <span class="text-gray-500">Balance Due</span>
                        <span class="font-bold ${last.balance_due > 0 ? 'text-yellow-400' : 'text-green-400'}">${fmt(last.balance_due)}</span>
                    </div>
                </div>`;
            }
            html += '</div>';
        }
        html += '</div>';
    });

    el.innerHTML = html;
}

// ═══════════════════════════════════════════════════════════════════════════════
// INIT
// ═══════════════════════════════════════════════════════════════════════════════
document.addEventListener('DOMContentLoaded', () => {
    loadDashboard();
    loadAnnualReport();
    loadLeadConversion();
    loadRegionalPerformance();
    loadCustomers();
});
