import React from 'react';
import { motion } from 'framer-motion';
import Countdown from './components/Countdown';
import RSVPForm from './components/RSVPForm';
import Gallery from './components/Gallery';
import Confetti from 'react-confetti';
import { useState, useEffect } from 'react';

const BirthdayInvitation = () => {
  const [showConfetti, setShowConfetti] = useState(false);
  const [windowDimensions, setWindowDimensions] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  });

  useEffect(() => {
    const handleResize = () => {
      setWindowDimensions({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const triggerConfetti = () => {
    setShowConfetti(true);
    setTimeout(() => setShowConfetti(false), 5000);
  };

  return (
    <div className="birthday-invitation">
      {showConfetti && (
        <Confetti
          width={windowDimensions.width}
          height={windowDimensions.height}
          recycle={false}
          numberOfPieces={200}
        />
      )}
      
      <motion.div 
        className="card"
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1, ease: "easeOut" }}
      >
        <motion.h1 
          className="header"
          initial={{ scale: 0.8 }}
          animate={{ scale: 1 }}
          transition={{ delay: 0.2, duration: 0.5 }}
        >
          Meghívó — Bori 16. születésnapja alkalmából
        </motion.h1>
        
        <motion.div 
          className="content"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4, duration: 0.5 }}
        >
          <p><span className="highlight">Meglepetéskoncert Borinak!</span> 💖</p>
          <p>Ezt a napot neked ajándékozzuk — gyere ünnepelni!</p>
        </motion.div>
        
        <motion.div 
          className="date-place"
          initial={{ scale: 0.9 }}
          animate={{ scale: 1 }}
          transition={{ delay: 0.6, duration: 0.5 }}
        >
          2026.03.14./15. @ Papp László Aréna
        </motion.div>
        
        <Countdown />
        
        <motion.div 
          className="content"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8, duration: 0.5 }}
        >
          <p>Kis meglepi és nagy ölelés vár.</p>
        </motion.div>
        
        <Gallery />
        
        <motion.button 
          className="rsvp-button"
          onClick={triggerConfetti}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1, duration: 0.5 }}
        >
          Megyek! 🎉
        </motion.button>
        
        <RSVPForm />
      </motion.div>
    </div>
  );
};

export default BirthdayInvitation;
