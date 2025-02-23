import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import CharacterCreation from './components/CharacterCreation';
import IdentityProfile from './components/IdentityProfile';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/create" element={<CharacterCreation />} />
        <Route path="/profile" element={<IdentityProfile />} />
      </Routes>
    </Router>
  );
}

export default App;
