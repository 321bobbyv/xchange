import { 
  createConfig, 
  http, 
  injected,
  connect, 
  disconnect, 
  reconnect,
  getAccount, 
  getBalance, 
  getEnsName, 
  signMessage,
  sendTransaction,
  waitForTransactionReceipt,
  watchAccount, 
  watchChainId 
} from 'https://esm.sh/@wagmi/core@2.10.0';
import { mainnet, sepolia } from 'https://esm.sh/@wagmi/core@2.10.0/chains';
import { parseEther, UserRejectedRequestError, verifyMessage } from 'https://esm.sh/viem@2.16.0';

// Token contract addresses
const USDC_MAINNET = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
const USDC_SEPOLIA = '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238'; // Testnet

// ERC-20 ABI (standard token interface)
const ERC20_ABI = [
  {
    name: 'balanceOf',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    name: 'transfer',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'recipient', type: 'address' },
      { name: 'amount', type: 'uint256' }
    ],
    outputs: [{ name: '', type: 'bool' }],
  },
  {
    name: 'decimals',
    type: 'function',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint8' }],
  }
];
const DEBUG = true;
const log = (...args) => DEBUG && console.log('%c[WALLET]', 'color: #00bfff; font-weight: bold;', ...args);
const warn = (...args) => console.warn('%c[WALLET WARN]', 'color: #ff9800;', ...args);
const err = (...args) => console.error('%c[WALLET ERROR]', 'color: #f44336;', ...args);
const BALANCE_CACHE_KEY = 'xchange_wallet_balance_cache';
const COINGECKO_API = 'https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd,eur';

log('Creating wagmi config...');
const wagmiConfig = createConfig({
  chains: [mainnet, sepolia],
  connectors: [injected()],
  transports: {
    [mainnet.id]: http('https://ethereum.publicnode.com'),
    [sepolia.id]: http('https://ethereum-sepolia.publicnode.com'),
  },
});

let walletState = {
  address: null,
  chain: null,
  connected: false,
  ethBalance: "0.00 ETH",
  usdcBalance: "0.00 USDC",
  balanceDisplay: "0.00 ETH | 0.00 USDC", // Combined display
  status: "Connect Wallet"
};
function updateWalletUI() {
  log('Updating UI →', { ...walletState });
  const statusElements = document.querySelectorAll('.wallet-status');
  statusElements.forEach(el => el.textContent = walletState.status);
  
  const balanceElements = document.querySelectorAll('.wallet-balance');
  balanceElements.forEach(el => el.textContent = walletState.balanceDisplay); // Shows both
  
  const addressElements = document.querySelectorAll('.wallet-address');
  addressElements.forEach(el => el.textContent = walletState.address || '');
  
  const connectedElements = document.querySelectorAll('.wallet-connected-info');
  connectedElements.forEach(el => el.style.display = walletState.connected ? 'flex' : 'none');
  
  const connectButtons = document.querySelectorAll('.wallet-connect-btn');
  connectButtons.forEach(btn => {
    btn.textContent = walletState.connected ? 'Disconnect' : 'Connect Wallet';
    btn.style.display = 'block';
  });
  
  const sendButtons = document.querySelectorAll('.wallet-send-btn');
  sendButtons.forEach(btn => {
    btn.disabled = !walletState.connected;
  });
}

function getCachedBalance(address) {
  try {
    const cached = localStorage.getItem(BALANCE_CACHE_KEY);
    if (!cached) return null;
    const data = JSON.parse(cached);
    // Only use cache if address matches
    if (data.address === address) {
      return data.balance;
    }
    return null;
  } catch (e) {
    return null;
  }
}

function setCachedBalance(address, balance) {
  try {
    localStorage.setItem(BALANCE_CACHE_KEY, JSON.stringify({
      address: address,
      balance: balance,
      timestamp: Date.now()
    }));
  } catch (e) {
    warn('Failed to cache balance', e);
  }
}
async function getUsdcBalance(address, chainId) {
  try {
    const { readContract } = await import('https://esm.sh/@wagmi/core@2.10.0');
    
    // Choose correct USDC contract based on chain
    const usdcContract = chainId === 1 ? USDC_MAINNET : USDC_SEPOLIA;
    
    const balance = await readContract(wagmiConfig, {
      address: usdcContract,
      abi: ERC20_ABI,
      functionName: 'balanceOf',
      args: [address],
      chainId: chainId,
    });
    
    // USDC has 6 decimals (not 18 like ETH)
    return Number(balance) / 1e6;
  } catch (e) {
    warn('Failed to get USDC balance', e);
    return 0;
  }
}
async function sendUsdc(toAddress, amountUsdc) {
  log('sendUsdc requested:', { to: toAddress, amount: amountUsdc });
  try {
    const account = getAccount(wagmiConfig);
    if (!account.address) {
      throw new Error("No wallet connected");
    }
    if (!toAddress || !toAddress.match(/^0x[a-fA-F0-9]{40}$/)) {
      throw new Error("Invalid recipient address");
    }
    
    const { writeContract, waitForTransactionReceipt } = await import('https://esm.sh/@wagmi/core@2.10.0');
    
    // Choose contract based on chain
    const usdcContract = account.chainId === 1 ? USDC_MAINNET : USDC_SEPOLIA;
    
    // USDC has 6 decimals
    const amountInSmallestUnit = BigInt(Math.floor(parseFloat(amountUsdc) * 1e6));
    
    log('Sending USDC transaction...');
    const hash = await writeContract(wagmiConfig, {
      address: usdcContract,
      abi: ERC20_ABI,
      functionName: 'transfer',
      args: [toAddress, amountInSmallestUnit],
    });
    
    log('USDC transaction sent! Hash:', hash);
    
    return {
      success: true,
      hash: hash,
      receipt: null,
      from: account.address,
      to: toAddress,
      amount: amountUsdc,
      currency: 'USDC'
    };
  } catch (error) {
    if (error instanceof UserRejectedRequestError || error.message.includes("User rejected")) {
      throw new Error("You rejected the transaction");
    }
    err('USDC transaction failed', error);
    throw error;
  }
}

async function setWallet(account) {
  log('setWallet called with account:', account);
  if (!account || account.status === "disconnected") {
    log('Wallet disconnected');
    walletState = {
      address: null,
      chain: null,
      connected: false,
      ethBalance: "0.00 ETH",
      usdcBalance: "0.00 USDC",
      balanceDisplay: "0.00 ETH | 0.00 USDC",
      status: "Connect Wallet"
    };
    localStorage.removeItem(BALANCE_CACHE_KEY);
  } else if (account.status === "connected") {
    log('Wallet connected!', { address: account.address, chainId: account.chainId });
    walletState.address = account.address;
    walletState.chain = account.chainId;
    walletState.connected = true;
    
    // Try cached balance first
    const cachedBalance = getCachedBalance(account.address);
    if (cachedBalance) {
      walletState.balanceDisplay = cachedBalance;
      updateWalletUI();
    }
    
    // Fetch ETH balance
    try {
      log('Fetching ETH balance...');
      const ethBalanceRaw = await getBalance(wagmiConfig, { address: account.address });
      const ethAmount = Number(ethBalanceRaw.formatted);
      
      // Fetch ETH price
      const prices = await getEthPrice();
      
      if (prices) {
        walletState.ethBalance = `${ethAmount.toFixed(4)} ETH ($${(ethAmount * prices.usd).toFixed(2)})`;
      } else {
        walletState.ethBalance = `${ethAmount.toFixed(4)} ETH`;
      }
      
      log('ETH balance:', walletState.ethBalance);
    } catch (e) {
      err('Failed to get ETH balance', e);
      walletState.ethBalance = "Error";
    }
    
    // Fetch USDC balance
    try {
      log('Fetching USDC balance...');
      const usdcAmount = await getUsdcBalance(account.address, account.chainId);
      walletState.usdcBalance = `${usdcAmount.toFixed(2)} USDC`;
      log('USDC balance:', walletState.usdcBalance);
    } catch (e) {
      err('Failed to get USDC balance', e);
      walletState.usdcBalance = "0.00 USDC";
    }
    
    // Combine for display
    walletState.balanceDisplay = `${walletState.ethBalance} | ${walletState.usdcBalance}`;
    setCachedBalance(account.address, walletState.balanceDisplay);
    
    // Fetch ENS name
    try {
      const ensName = await getEnsName(wagmiConfig, { address: account.address });
      walletState.status = ensName || `${account.address.slice(0, 6)}...${account.address.slice(-4)}`;
    } catch (e) {
      walletState.status = `${account.address.slice(0, 6)}...${account.address.slice(-4)}`;
    }
  }
  updateWalletUI();
}

async function toggleWallet() {
  const account = getAccount(wagmiConfig);
  log('toggleWallet → current status:', account.status);
  if (account.status === "connected") {
    log('Disconnecting wallet...');
    try {
      await disconnect(wagmiConfig);
      log('Disconnected successfully');
    } catch (e) {
      err('Disconnect failed', e);
    }
  } else {
    log('Attempting to connect wallet...');
    try {
      await reconnect(wagmiConfig);
      log('Reconnect attempted (may be no-op)');
      const result = await connect(wagmiConfig, { connector: wagmiConfig.connectors[0] });
      log('connect() succeeded', result);
      await setWallet(getAccount(wagmiConfig));
    } catch (error) {
      err('Connection failed', error);
      if (error instanceof UserRejectedRequestError || error.message.includes("User rejected")) {
        alert("You rejected the wallet connection request.");
      } else {
        alert("Failed to connect wallet. Is MetaMask (or another wallet) installed and unlocked?");
      }
    }
  }
}

async function signWalletMessage(message) {
  log('signWalletMessage requested:', message);
  try {
    const account = getAccount(wagmiConfig);
    if (!account.address) {
      throw new Error("No wallet connected");
    }
    log('Signing message with address:', account.address);
    const signature = await signMessage(wagmiConfig, {
      account: account,
      message: message
    });
    log('Signature successful:', signature);
    return { address: account.address, signature, message };
  } catch (error) {
    if (error instanceof UserRejectedRequestError || error.message.includes("User rejected")) {
      log('User rejected signature');
      throw new Error("You rejected the signature request");
    }
    err('Signature failed', error);
    throw error;
  }
}

async function sendEth(toAddress, amountEth) {
  log('sendEth requested:', { to: toAddress, amount: amountEth });
  try {
    const account = getAccount(wagmiConfig);
    if (!account.address) {
      throw new Error("No wallet connected");
    }
    if (!toAddress || !toAddress.match(/^0x[a-fA-F0-9]{40}$/)) {
      throw new Error("Invalid recipient address");
    }
    const value = parseEther(amountEth);
    log('Parsed amount to wei:', value.toString());
    log('Sending transaction...');
    const hash = await sendTransaction(wagmiConfig, {
      to: toAddress,
      value: value,
    });
    log('Transaction sent! Hash:', hash);
    log('Note: Transaction confirmation will happen on Urbit backend');
    return {
      success: true,
      hash: hash,
      receipt: null,
      from: account.address,
      to: toAddress,
      amount: amountEth
    };
  } catch (error) {
    if (error instanceof UserRejectedRequestError || error.message.includes("User rejected")) {
      log('User rejected transaction');
      throw new Error("You rejected the transaction");
    }
    err('Transaction failed', error);
    throw error;
  }
}

async function verifyTransactionExists(txHash) {
  log('verifyTransactionExists requested:', txHash);
  
  try {
    const { getTransaction } = await import('https://esm.sh/@wagmi/core@2.10.0');
    
    log('Checking if transaction exists on blockchain...');
    const tx = await getTransaction(wagmiConfig, {
      hash: txHash,
    });
    
    // If tx is not null/undefined, it exists
    const exists = !!tx;
    log('Transaction exists:', exists);
    
    return exists;
    
  } catch (error) {
    err('Transaction check failed:', error);
    return false;
  }
}

async function sendToShip(shipName, amountEth) {
  try {
    log('sendToShip requested:', { ship: shipName, amount: amountEth });
    
    const account = getAccount(wagmiConfig);
    if (!account.address) {
      throw new Error("No wallet connected");
    }
    
    const response = await fetch(`/apps/xchange/get-ship-wallet?ship=${shipName}`);
    const walletInfo = await response.json();
    
    if (!walletInfo.address) {
      alert(`${shipName} has no linked wallet`);
      return;
    }
    
    log('Retrieved wallet info for', shipName, walletInfo);
    
    const isValid = await verifyMessage({
      address: walletInfo.address,
      message: walletInfo.message,
      signature: walletInfo.signature
    });
    
    log('Signature verification result:', isValid);
    
    if (!isValid) {
      alert(
        `⚠️ WARNING: ${shipName}'s wallet signature is INVALID!\n\n` +
        `This could be:\n` +
        `- A compromised ship\n` +
        `- Corrupted data\n` +
        `- An attack attempt\n\n` +
        `Do NOT send money!`
      );
      return;
    }
    
    const confirmed = confirm(
      `Send ${amountEth} ETH to ${shipName}?\n\n` +
      `Verified wallet: ${walletInfo.address}\n\n` +
      `✅ Signature verified - this wallet is cryptographically linked to ${shipName}`
    );
    
    if (!confirmed) {
      log('User cancelled transaction');
      return;
    }
    
    const result = await sendEth(walletInfo.address, amountEth);
    await recordShipTransaction(shipName, result);  // Already has .to from sendEth
    alert(`✅ Successfully sent ${amountEth} ETH to ${shipName}!`);
  } catch (error) {
    err('sendToShip failed:', error);
    alert(`Failed to send: ${error.message}`);
  }
}

async function handleSendToShipForm(event) {
  event.preventDefault();
  const form = event.target;
  const shipName = form.querySelector('input[name="ship"]').value.trim();
  const amount = form.querySelector('input[name="amount"]').value.trim();
  if (!shipName || !amount) {
    alert('Please enter both ship name and amount');
    return;
  }
  await sendToShip(shipName, amount);
}

async function recordShipTransaction(shipName, txData) {
  try {
    const account = getAccount(wagmiConfig);
    
    const formData = new FormData();
    formData.append('recipient', shipName);
    formData.append('amount', txData.amount);
    formData.append('txHash', txData.hash);
    formData.append('fromAddress', account.address);  // ADD THIS
    formData.append('toAddress', txData.to);           // ADD THIS
    formData.append('payMemo', '');
    
    const response = await fetch('/apps/xchange/record-ship-transfer', {
      method: 'POST',
      body: formData
    });
    
    if (response.ok) {
      log('Ship transaction recorded');
    } else {
      warn('Failed to record ship transaction');
    }
  } catch (e) {
    warn('Could not record ship transaction:', e);
  }
}

async function handleSendForm(event) {
  event.preventDefault();
  const form = event.target;
  const submitBtn = form.querySelector('button[type="submit"]');
  const statusDiv = document.getElementById('send-status');
  const toAddress = form.querySelector('input[name="to"]').value.trim();
  const amount = form.querySelector('input[name="amount"]').value.trim();
  if (!toAddress || !amount) {
    statusDiv.textContent = 'Please fill in all fields';
    statusDiv.style.color = '#f44336';
    return;
  }
  const originalText = submitBtn.textContent;
  submitBtn.textContent = 'Sending...';
  submitBtn.disabled = true;
  statusDiv.textContent = 'Waiting for wallet confirmation...';
  statusDiv.style.color = '#666';
  try {
    log('Initiating send transaction...');
    const result = await sendEth(toAddress, amount);
    statusDiv.innerHTML = `
      <div style="color: #4caf50; font-weight: bold;">✓ Transaction Successful!</div>
      <div style="margin-top: 8px; font-size: 14px;">
        <div>Hash: <a href="https://etherscan.io/tx/${result.hash}" target="_blank" style="color: #2196f3;">${result.hash.slice(0, 10)}...</a></div>
        <div>Sent ${result.amount} ETH to ${result.to.slice(0, 10)}...</div>
      </div>
    `;
    form.reset();
    await recordTransaction(result);
  } catch (error) {
    err('Send failed:', error);
    statusDiv.textContent = `Error: ${error.message}`;
    statusDiv.style.color = '#f44336';
  } finally {
    submitBtn.textContent = originalText;
    submitBtn.disabled = false;
  }
}

async function recordTransaction(txData) {
  try {
    const formData = new FormData();
    formData.append('hash', txData.hash);
    formData.append('from', txData.from);
    formData.append('to', txData.to);
    formData.append('amount', txData.amount);
    formData.append('timestamp', Date.now().toString());
    formData.append('status', txData.receipt.status);
    const response = await fetch('/apps/xchange/record-tx', {
      method: 'POST',
      body: formData
    });
    if (response.ok) {
      log('Transaction recorded to backend');
    } else {
      warn('Failed to record transaction to backend');
    }
  } catch (e) {
    warn('Could not record transaction:', e);
  }
}

async function linkWallet(event) {
  event.preventDefault();
  const button = event.target;
  const originalText = button.textContent;
  button.textContent = "Signing...";
  button.disabled = true;
  
  log('linkWallet initiated');
  
  try {
    const account = getAccount(wagmiConfig);
    if (!account.address) {
      throw new Error("Please connect your wallet first");
    }
    
    const shipElement = document.querySelector('.ship-name-link');
    const shipName = shipElement ? shipElement.textContent.trim() : 'your Urbit ship';
    
    log('Linking wallet to ship:', shipName);
    
    // Prompt for nickname
    const nickname = prompt(
      "Give this wallet a nickname (optional):\n\n" +
      "Examples: 'Main Wallet', 'Trading', 'Cold Storage'",
      "My Wallet"
    );
    
    if (nickname === null) {
      // User cancelled
      throw new Error("Cancelled");
    }
    
    const message = `I verify that I own wallet ${account.address} and link it to my Urbit ship ${shipName}`;
    const result = await signWalletMessage(message);
    
    log('Signature obtained, submitting form...', result);
    
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/apps/xchange/link-wallet';
    
    const fields = {
      address: result.address,
      signature: result.signature,
      message: result.message,
      nickname: nickname || 'My Wallet',
      timestamp: Date.now().toString()
    };
    
    Object.entries(fields).forEach(([key, value]) => {
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = key;
      input.value = value;
      form.appendChild(input);
    });
    
    document.body.appendChild(form);
    log('Submitting wallet linking form...');
    form.submit();
    
  } catch (error) {
    err('Wallet linking failed:', error);
    if (error.message !== "Cancelled") {
      alert(error.message || "Wallet linking failed");
    }
    button.textContent = originalText;
    button.disabled = false;
  }
}
//  fetch eth price in $ and Euro's
async function getEthPrice() {
  try {
    const response = await fetch(COINGECKO_API);
    const data = await response.json();
    return {
      usd: data.ethereum.usd,
      eur: data.ethereum.eur
    };
  } catch (e) {
    warn('Failed to fetch ETH price', e);
    return null;
  }
}
// Edit wallet nickname function
function editNickname(address, currentName) {
  log('editNickname called for address:', address);
  
  const newName = prompt('Enter new nickname for this wallet:', currentName);
  
  if (newName && newName !== currentName) {
    log('Submitting nickname change:', { address, newName });
    
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/apps/xchange/edit-wallet-nickname';
    
    const addressInput = document.createElement('input');
    addressInput.type = 'hidden';
    addressInput.name = 'address';
    addressInput.value = address;
    form.appendChild(addressInput);
    
    const nicknameInput = document.createElement('input');
    nicknameInput.type = 'hidden';
    nicknameInput.name = 'nickname';
    nicknameInput.value = newName;
    form.appendChild(nicknameInput);
    
    document.body.appendChild(form);
    form.submit();
  } else {
    log('Nickname edit cancelled or unchanged');
  }
}

document.addEventListener('DOMContentLoaded', () => {
  log('DOM loaded – initializing Xchange Wallet');
  
  watchAccount(wagmiConfig, {
    onChange: (account) => {
      log('watchAccount → account changed', account);
      setWallet(account);
    }
  });
  
  watchChainId(wagmiConfig, {
    onChange: (chainId) => {
      log('Chain changed to', chainId);
      setWallet(getAccount(wagmiConfig));
    }
  });
  
  log('Attempting auto-reconnect...');
  reconnect(wagmiConfig);
  
  document.querySelectorAll('.wallet-connect-btn').forEach(btn => {
    btn.addEventListener('click', toggleWallet);
    log('Connect button bound');
  });
  
  document.querySelectorAll('.wallet-link-btn').forEach(btn => {
    btn.addEventListener('click', linkWallet);
    log('Link wallet button bound');
  });
  
  // Bind edit nickname buttons
  document.querySelectorAll('.edit-nickname-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const address = e.target.getAttribute('data-address');
      const nickname = e.target.getAttribute('data-nickname');
      editNickname(address, nickname);
    });
    log('Edit nickname button bound');
  });
  
  const sendForm = document.getElementById('send-eth-form');
  if (sendForm) {
    sendForm.addEventListener('submit', handleSendForm);
    log('Send form bound');
  }
  
  const sendToShipForm = document.getElementById('send-to-ship-form');
  if (sendToShipForm) {
    sendToShipForm.addEventListener('submit', handleSendToShipForm);
    log('Send-to-ship form bound');
  }
  
  setWallet(getAccount(wagmiConfig));
});

// Export functions to window for onclick handlers
window.XchangeWallet = {
  toggleWallet,
  signWalletMessage,
  linkWallet,
  sendEth,
  sendUsdc,
  sendToShip,
  editNickname,
  verifyTransactionExists,
  getState: () => walletState,
  debug: { log, warn, err }
};

log('XchangeWallet loaded and ready');