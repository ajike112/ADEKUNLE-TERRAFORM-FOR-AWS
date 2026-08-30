async function loadData() {
  try {
    const accountsRes = await fetch('/api/accounts');
    const accounts = await accountsRes.json();
    document.getElementById('accounts-data').textContent =
      JSON.stringify(accounts, null, 2);

    const txRes = await fetch('/api/transactions');
    const tx = await txRes.json();
    document.getElementById('transactions-data').textContent =
      JSON.stringify(tx, null, 2);

    const budgetRes = await fetch('/api/tools/budget');
    const budget = await budgetRes.json();
    document.getElementById('budget-data').textContent =
      JSON.stringify(budget, null, 2);
  } catch (err) {
    console.error(err);
  }
}

loadData();
