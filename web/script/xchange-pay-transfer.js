// xchange-pay-transfer.js
import { parseEther } from 'https://esm.sh/viem@2.16.0';
let recipientWalletAddress = null;

document.addEventListener('DOMContentLoaded', () => {
  const sendBtn = document.getElementById('send-eth-btn');
  
  if (sendBtn) {
    sendBtn.addEventListener('click', initiateTransfer);
  }
  
  // Enable send button when wallet is found and amount is entered
  const amountInput = document.getElementById('amount-eth');
  if (amountInput) {
    amountInput.addEventListener('input', validateForm);
  }
  
  // Add wallet lookup form handler
  const lookupForm = document.querySelector('form[action="/apps/xchange/pay-transfer"]');
  if (lookupForm) {
    lookupForm.addEventListener('submit', handleWalletLookup);
  }
});

// Handle wallet lookup via AJAX
async function handleWalletLookup(e) {
  e.preventDefault();
  
  const shipInput = document.getElementById('recipient-ship');
  const ship = shipInput.value.trim();
  
  if (!ship) {
    showStatus('Please enter a ship name', 'error');
    return;
  }
  
  // Get the lookup button and disable it
  const lookupBtn = e.target.querySelector('button[type="submit"]');
  const originalBtnText = lookupBtn.textContent;
  lookupBtn.disabled = true;
  lookupBtn.textContent = 'Looking up...';
  
  showStatus('Looking up wallet...', 'info');
  
  try {
    // Use URLSearchParams instead of FormData for URL-encoded format
    const params = new URLSearchParams();
    params.append('recipient-ship', ship);
    
    // Start the lookup
    const response = await fetch('/apps/xchange/pay-transfer', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: params.toString()
    });
    
    const data = await response.json();
    
    if (data.status === 'pending') {
      // Poll for results
      const result = await pollForWalletResult(data.request_id);
      
      if (result.success) {
        recipientWalletAddress = result.wallet;
        
        // Display wallet info
        const walletInfo = document.getElementById('wallet-info');
        const walletDisplay = document.getElementById('recipient-wallet-display');
        
        if (walletInfo && walletDisplay) {
          // Show both wallet address and nickname
          if (result.nickname) {
            walletDisplay.innerHTML = `${result.wallet}<br><em style="color: #666; font-size: 0.9em;">${result.nickname}</em>`;
          } else {
            walletDisplay.textContent = result.wallet;
          }
          walletInfo.style.display = 'block';
        }
        
        showStatus(`Wallet found!`, 'success');
        validateForm();
        
      } else {
        showStatus(`Error: ${result.error || 'Wallet not found'}`, 'error');
        recipientWalletAddress = null;
        
        // Hide wallet info if it was previously shown
        const walletInfo = document.getElementById('wallet-info');
        if (walletInfo) {
          walletInfo.style.display = 'none';
        }
        
        validateForm();
      }
    } else {
      // Handle unexpected response
      showStatus('Unexpected response from server', 'error');
      recipientWalletAddress = null;
      validateForm();
    }
    
  } catch (error) {
    console.error('Wallet lookup error:', error);
    showStatus(`Error: ${error.message}`, 'error');
    recipientWalletAddress = null;
    validateForm();
    
  } finally {
    // Re-enable the lookup button
    lookupBtn.disabled = false;
    lookupBtn.textContent = originalBtnText;
  }
}

// Poll for wallet lookup results
async function pollForWalletResult(requestId, maxAttempts = 30) {
  console.log('Starting poll with requestId:', requestId);
  
  for (let i = 0; i < maxAttempts; i++) {
    // Wait 1 second between polls
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    try {
      const url = `/apps/xchange/wallet-status?id=${requestId}`;
      console.log('Polling URL:', url);
      
      const response = await fetch(url);
      console.log('Response status:', response.status);
      console.log('Response ok:', response.ok);
      
      // Even if response is 400, try to parse the JSON
      const data = await response.json();
      console.log('Response data:', data);
      
      // Check if we got a result (success or error)
      if (data.status !== 'pending') {
        console.log('Got final result:', data);
        return data;
      }
      
      // Still pending, continue polling
      console.log(`Poll attempt ${i + 1}/${maxAttempts}: still pending...`);
      
    } catch (error) {
      console.error('Poll error:', error);
      // Continue polling even on errors
    }
  }
  
  // Timeout after all attempts
  throw new Error('Timeout waiting for wallet lookup');
}

function validateForm() {
  const amountInput = document.getElementById('amount-eth');
  const amount = amountInput ? parseFloat(amountInput.value) : 0;
  const sendBtn = document.getElementById('send-eth-btn');
  
  if (sendBtn) {
    if (recipientWalletAddress && amount > 0) {
      sendBtn.disabled = false;
    } else {
      sendBtn.disabled = true;
    }
  }
}

async function initiateTransfer() {
  const amount = parseFloat(document.getElementById('amount-eth').value);
  const ship = document.getElementById('recipient-ship').value.trim();
  const memo = document.getElementById('pay-memo')?.value.trim() || '';
  const currency = document.getElementById('currency-select')?.value || 'ETH'; // ← ADD THIS
  
  if (!recipientWalletAddress || !amount) {
    showStatus('Please complete all fields', 'error');
    return;
  }
  
  showStatus(`Initiating ${currency} transfer...`, 'info');
  
  try {
    if (!window.XchangeWallet) {
      throw new Error('Wallet module not loaded. Please refresh the page.');
    }
    
    let result;
    
    // Choose send function based on currency
    if (currency === 'USDC') {
      result = await window.XchangeWallet.sendUsdc(recipientWalletAddress, amount.toString());
    } else {
      result = await window.XchangeWallet.sendEth(recipientWalletAddress, amount.toString());
    }
    
    if (result && result.success) {
      showStatus(`Transaction sent! Hash: ${result.hash}`, 'success');
      
      // Record with currency type
      await recordShipTransfer(ship, amount, result.hash, result.from, result.to, memo, currency);
      
      setTimeout(() => {
        window.location.reload();
      }, 1500);
    } else {
      showStatus(`Transaction failed`, 'error');
    }
    
  } catch (error) {
    console.error('Transfer error:', error);
    showStatus(`Error: ${error.message}`, 'error');
  }
}

// Update recordShipTransfer to include currency
async function recordShipTransfer(recipientShip, amount, txHash, fromAddress, toAddress, payMemo = '', currency = 'ETH') {
  console.log('[recordShipTransfer] Called with:', {
    recipientShip,
    amount,
    txHash,
    fromAddress,
    toAddress,
    payMemo,
    currency  // ← ADD THIS
  });
  
  try {
    const params = new URLSearchParams();
    params.append('recipient', recipientShip);
    params.append('amount', amount.toString());
    
   if (currency === 'ETH') {
      const amountWei = parseEther(amount.toString());
      params.append('amountWei', amountWei.toString());
    } else if (currency === 'USDC') {
      const amountRaw = Math.floor(parseFloat(amount) * 1e6);
      params.append('amountWei', amountRaw.toString()); // raw USDC units (6 decimals)
    }
    
    params.append('txHash', txHash);
    params.append('fromAddress', fromAddress);
    params.append('toAddress', toAddress);
    params.append('payMemo', payMemo);
    params.append('currency', currency);
    
    const response = await fetch('/apps/xchange/record-ship-transfer', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: params.toString()
    });
    
    if (!response.ok) {
      console.error('[recordShipTransfer] Failed');
    } else {
      console.log('[recordShipTransfer] Success');
    }
  } catch (error) {
    console.error('[recordShipTransfer] Error:', error);
  }
}

function showStatus(message, type) {
  const statusDiv = document.getElementById('tx-status');
  if (statusDiv) {
    statusDiv.textContent = message;
    statusDiv.className = 'tx-status ' + type;
    statusDiv.style.display = 'block';
  }
}