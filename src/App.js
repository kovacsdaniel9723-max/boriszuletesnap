import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import BirthdayInvitation from './pages/BirthdayInvitation';
import Admin from './pages/Admin';
import './App.css';

function App() {
  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/" element={<BirthdayInvitation />} />
          <Route path="/admin" element={<Admin />} />
        </Routes>
        <Toaster 
          position="top-center"
          toastOptions={{
            duration: 4000,
            style: {
              background: '#ff6b6b',
              color: '#fff',
            },
          }}
        />
      </div>
    </Router>
  );
}

export default App;
