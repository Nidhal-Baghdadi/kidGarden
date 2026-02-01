// app/assets/javascripts/background_doodles.js

document.addEventListener('DOMContentLoaded', function() {
  // Create floating doodle elements
  createFloatingDoodles();
});

function createFloatingDoodles() {
  // Create container for doodles
  const doodleContainer = document.createElement('div');
  doodleContainer.id = 'doodle-container';
  doodleContainer.style.position = 'fixed';
  doodleContainer.style.top = '0';
  doodleContainer.style.left = '0';
  doodleContainer.style.width = '100%';
  doodleContainer.style.height = '100%';
  doodleContainer.style.pointerEvents = 'none';
  doodleContainer.style.zIndex = '1';
  doodleContainer.style.overflow = 'hidden';
  doodleContainer.style.opacity = '0.15'; // Subtle effect
  document.body.appendChild(doodleContainer);

  // Doodle SVG definitions
  const doodleSVGs = [
    // Smile face doodle
    '<svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="10" stroke="var(--primary)" stroke-width="1" fill="none"/><circle cx="8" cy="9" r="1" fill="var(--primary)"/><circle cx="16" cy="9" r="1" fill="var(--primary)"/><path d="M8 15 Q12 18 16 15" stroke="var(--primary)" stroke-width="1" fill="none"/></svg>',
    
    // Star doodle
    '<svg width="30" height="30" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 2 L15.09 8.26 L22 9.27 L17 14.14 L18.18 21.02 L12 17.77 L5.82 21.02 L7 14.14 L2 9.27 L8.91 8.26 Z" stroke="var(--secondary)" stroke-width="1" fill="none"/></svg>',
    
    // Heart doodle
    '<svg width="30" height="30" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M20.84 4.61 C20.33 4.1 19.66 4.1 19.15 4.61 L12 11.76 L4.85 4.61 C4.34 4.1 3.67 4.1 3.16 4.61 C2.65 5.12 2.65 5.95 3.16 6.46 L10.31 13.61 L3.16 20.76 C2.65 21.27 2.65 22.1 3.16 22.61 C3.67 23.12 4.34 23.12 4.85 22.61 L12 15.46 L19.15 22.61 C19.66 23.12 20.33 23.12 20.84 22.61 C21.35 22.1 21.35 21.27 20.84 20.76 L13.69 13.61 L20.84 6.46 C21.35 5.95 21.35 5.12 20.84 4.61 Z" stroke="var(--accent)" stroke-width="1" fill="none"/></svg>',
    
    // Balloon doodle
    '<svg width="35" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 3 C8.69 3 6 5.69 6 9 C6 13.5 12 21 12 21 C12 21 18 13.5 18 9 C18 5.69 15.31 3 12 3 Z" stroke="var(--primary)" stroke-width="1" fill="none"/><path d="M12 21 L12 22 M12 22 L10 24 M12 22 L14 24" stroke="var(--primary)" stroke-width="1"/></svg>',
    
    // Sun doodle
    '<svg width="35" height="35" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="5" stroke="var(--warning)" stroke-width="1" fill="none"/><path d="M12 1 V3 M12 21 V23 M4.22 4.22 L5.64 5.64 M18.36 18.36 L19.78 19.78 M1 12 H3 M21 12 H23 M4.22 19.78 L5.64 18.36 M18.36 5.64 L19.78 4.22" stroke="var(--warning)" stroke-width="1"/></svg>',
    
    // Cloud doodle
    '<svg width="45" height="25" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18 10 H17 L16.2 8.2 C15.5 6.9 14.1 6 12.5 6 C10.5 6 9 7.5 9 9.5 C7 10 5.5 11.5 5.5 13.5 C5.5 15.5 7 17 9 17 H18 C20 17 22 15 22 13 C22 11.5 20.5 10 18 10 Z" stroke="var(--muted-foreground)" stroke-width="1" fill="none"/></svg>'
  ];

  // Create multiple doodles
  for (let i = 0; i < 15; i++) {
    createDoodleElement(doodleContainer, doodleSVGs);
  }

  // Add mouse move interaction
  document.addEventListener('mousemove', function(e) {
    const doodles = document.querySelectorAll('.floating-doodle');
    doodles.forEach(doodle => {
      const speedFactor = parseFloat(doodle.dataset.speed) || 0.05;
      const rect = doodle.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;
      
      const deltaX = e.clientX - centerX;
      const deltaY = e.clientY - centerY;
      
      // Calculate distance and angle
      const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
      const maxDistance = Math.sqrt(window.innerWidth * window.innerWidth + window.innerHeight * window.innerHeight);
      const intensity = Math.min(distance / maxDistance, 0.1) * speedFactor;
      
      // Calculate movement based on mouse position
      const moveX = (deltaX / distance) * intensity * 10;
      const moveY = (deltaY / distance) * intensity * 10;
      
      // Apply subtle movement
      doodle.style.transform = `translate(${moveX}px, ${moveY}px)`;
    });
  });
}

function createDoodleElement(container, doodleSVGs) {
  const doodle = document.createElement('div');
  doodle.className = 'floating-doodle';
  doodle.style.position = 'absolute';
  doodle.style.opacity = '0.3';
  doodle.style.transition = 'transform 0.3s ease';
  doodle.style.pointerEvents = 'none';
  
  // Randomly select a doodle SVG
  const randomSVG = doodleSVGs[Math.floor(Math.random() * doodleSVGs.length)];
  doodle.innerHTML = randomSVG;
  
  // Random position
  const posX = Math.random() * 100;
  const posY = Math.random() * 100;
  doodle.style.left = `${posX}%`;
  doodle.style.top = `${posY}%`;
  
  // Random size
  const size = 20 + Math.random() * 30;
  doodle.style.width = `${size}px`;
  doodle.style.height = `${size}px`;
  
  // Random rotation
  const rotation = Math.random() * 360;
  doodle.style.transform = `rotate(${rotation}deg)`;
  
  // Random speed factor for mouse interaction
  doodle.dataset.speed = (0.02 + Math.random() * 0.08).toString();
  
  // Add subtle animation
  doodle.style.animation = `float-${Math.floor(Math.random() * 4) + 1} ${15 + Math.random() * 15}s infinite ease-in-out`;
  doodle.style.animationDelay = `${Math.random() * 5}s`;
  
  container.appendChild(doodle);
}

// Add CSS for animations
const style = document.createElement('style');
style.textContent = `
  @keyframes float-1 {
    0%, 100% { transform: translateY(0) rotate(0deg); }
    50% { transform: translateY(-10px) rotate(5deg); }
  }
  
  @keyframes float-2 {
    0%, 100% { transform: translate(0, 0) rotate(0deg); }
    50% { transform: translate(5px, -5px) rotate(-5deg); }
  }
  
  @keyframes float-3 {
    0%, 100% { transform: translateY(0) rotate(0deg); }
    50% { transform: translateY(-15px) rotate(3deg); }
  }
  
  @keyframes float-4 {
    0%, 100% { transform: translate(0, 0) rotate(0deg); }
    25% { transform: translate(-5px, -5px) rotate(-3deg); }
    50% { transform: translate(3px, -10px) rotate(2deg); }
    75% { transform: translate(8px, -5px) rotate(5deg); }
  }
  
  .floating-doodle {
    will-change: transform;
  }
  
  #doodle-container {
    transition: opacity 0.5s ease;
  }
  
  body.loading #doodle-container {
    opacity: 0;
  }
`;
document.head.appendChild(style);