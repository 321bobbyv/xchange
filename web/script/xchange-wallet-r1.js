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
  watchAccount, 
  watchChainId 
} from 'https://esm.sh/@wagmi/core@2.10.0';
import { mainnet, sepolia } from 'https://esm.sh/@wagmi/core@2.10.0/chains';
import { fromHex, UserRejectedRequestError } from 'https://esm.sh/viem@2.16.0';
// Initialize Wagmi configuration
const wagmiConfig = createConfig({
  chains: [mainnet, sepolia],
  connectors: [injected()],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(),
  },
});
// Store wallet state
let walletState = {
  address: null,
  chain: null,
  connected: false,
  balance: "0.00 ETH",
  status: "Connect Wallet"
};
// Update UI with wallet state
function updateWalletUI() {
  // Update status button
  const statusElements = document.querySelectorAll('.wallet-status');
  statusElements.forEach(el => {
    el.textContent = walletState.status;
  });
  // Update balance
  const balanceElements = document.querySelectorAll('.wallet-balance');
  balanceElements.forEach(el => {
    el.textContent = walletState.balance;
  });
  // Update address
  const addressElements = document.querySelectorAll('.wallet-address');
  addressElements.forEach(el => {
    el.textContent = walletState.address || '';
  });
  // Show/hide connected info
  const connectedElements = document.querySelectorAll('.wallet-connected-info');
  connectedElements.forEach(el => {
    el.style.display = walletState.connected ? 'block' : 'none';
  });

  // Update connect button
  const connectButtons = document.querySelectorAll('.wallet-connect-btn');
  connectButtons.forEach(btn => {
    btn.textContent = walletState.connected ? 'Disconnect' : 'Connect Wallet';
  });
}
// Set wallet state
async function setWallet(account) {
  if (!account || account.status === "disconnected") {
    walletState = {
      address: null,
      chain: null,
      connected: false,
      balance: "0.00 ETH",
      status: "Connect Wallet"
    };
  } else if (account.status === "connected") {
    walletState.address = account.address;
    walletState.chain = account.chainId;
    walletState.connected = true;
    // Get balance
    try {
      const balance = await getBalance(wagmiConfig, { address: account.address });
      walletState.balance = `${Number(balance.formatted).toFixed(4)} ETH`;
    } catch (e) {
      console.error("Error getting balance:", e);
    }
    // Get ENS name or format address
    try {
      const ensName = await getEnsName(wagmiConfig, { address: account.address });
      walletState.status = ensName || `${account.address.slice(0, 6)}...${account.address.slice(-4)}`;
    } catch (e) {
      walletState.status = `${account.address.slice(0, 6)}...${account.address.slice(-4)}`;
    }
  }
  updateWalletUI();
}
// Toggle wallet connection
async function toggleWallet() {
  const account = getAccount(wagmiConfig); 
  if (account.status === "connected") {
    // Disconnect
    await disconnect(wagmiConfig);
  } else {
    // Connect
    try {
      await reconnect(wagmiConfig);
      const result = await connect(wagmiConfig, { 
        connector: wagmiConfig.connectors[0] 
      });
      await setWallet(getAccount(wagmiConfig));
    } catch (error) {
      console.error("Error connecting wallet:", error);
      alert("Failed to connect wallet. Please make sure MetaMask is installed.");
    }
  }
}
// Sign a message with the connected wallet
async function signWalletMessage(message) {
  try {
    const account = getAccount(wagmiConfig);
    if (!account.address) {
      throw new Error("No wallet connected");
    }
    const signature = await signMessage(wagmiConfig, {
      account: account,
      message: message
    });
    return {
      address: account.address,
      signature: signature,
      message: message
    };
  } catch (error) {
    if (error instanceof UserRejectedRequestError || 
        error.message.includes("User rejected")) {
      throw new Error("User rejected the signature request");
    }
    throw error;
  }
}
// Link wallet form submission
async function linkWallet(event) {
  event.preventDefault();
  const button = event.target;
  const originalText = button.textContent;
  button.textContent = "Signing...";
  button.disabled = true;
  try {
    const account = getAccount(wagmiConfig);
    if (!account.address) {
      throw new Error("Please connect your wallet first");
    }
    // Get ship name from page
    const shipElement = document.querySelector('.ship-name-link');
    const shipName = shipElement ? shipElement.textContent : 'your Urbit';
    // Sign message
    const message = `I verify that I own wallet ${account.address} and link it to my Urbit ship ${shipName}`;
    const result = await signWalletMessage(message);
    // Submit form
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/apps/xchange/link-wallet';
    const fields = {
      'address': result.address,
      'signature': result.signature,
      'message': result.message,
      'timestamp': Date.now().toString()
    };
    Object.entries(fields).forEach(([key, value]) => {
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = key;
      input.value = value;
      form.appendChild(input);
    });
    document.body.appendChild(form);
    form.submit();
  } catch (error) {
    alert(error.message);
    button.textContent = originalText;
    button.disabled = false;
  }
}
// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
  // Set up watchers
  watchAccount(wagmiConfig, {
    onChange: (account) => {
      setWallet(account);
    }
  });
  watchChainId(wagmiConfig, {
    onChange: () => {
      setWallet(getAccount(wagmiConfig));
    }
  });
  // Try to reconnect
  reconnect(wagmiConfig);
  // Set up event listeners
  document.querySelectorAll('.wallet-connect-btn').forEach(btn => {
    btn.addEventListener('click', toggleWallet);
  });
  document.querySelectorAll('.wallet-link-btn').forEach(btn => {
    btn.addEventListener('click', linkWallet);
  });
});
// Export functions for use in inline scripts
window.XchangeWallet = {
  toggleWallet,
  signWalletMessage,
  linkWallet,
  getState: () => walletState
};