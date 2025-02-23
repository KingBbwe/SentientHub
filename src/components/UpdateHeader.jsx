import React, { useState } from 'react';
import { AuthClient } from '@dfinity/auth-client';
import { Plug } from 'plugwallet-sdk';

const UpdateHeader = ({ setIdentity, setWallet }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isWalletConnected, setIsWalletConnected] = useState(false);

  const handleLogin = async () => {
    const authClient = await AuthClient.create();
    await authClient.login({
      identityProvider: "https://identity.ic0.app",
      onSuccess: async () => {
        const identity = authClient.getIdentity();
        setIdentity(identity);
        setIsAuthenticated(true);
      },
    });
  };

  const connectPlugWallet = async () => {
    try {
      const plug = await Plug.connect();
      if (plug) {
        setWallet(plug);
        setIsWalletConnected(true);
      }
    } catch (error) {
      console.error("Failed to connect Plug Wallet:", error);
    }
  };

  return (
    <header className="bg-gray-800 text-white p-4 flex justify-between">
      <h1 className="text-2xl">Sentience Hub</h1>
      <div className="flex gap-4">
        <button onClick={handleLogin} className="bg-blue-500 px-4 py-2 rounded">
          {isAuthenticated ? "Signed In" : "Sign In with Internet Identity"}
        </button>
        <button onClick={connectPlugWallet} className="bg-green-500 px-4 py-2 rounded">
          {isWalletConnected ? "Wallet Connected" : "Connect Plug Wallet"}
        </button>
      </div>
    </header>
  );
};

export default UpdateHeader;
