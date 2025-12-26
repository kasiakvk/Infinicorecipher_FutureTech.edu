// Game state variables
let currentChallenge = 0;
let totalPoints = 0;
let galaxiesUnlocked = 0;
let currentLevel = 1;

// Challenge data
const challenges = [
    {
        title: "Challenge 1: Basic Math",
        description: "What is 5 + 7?",
        answer: "12",
        points: 10
    },
    {
        title: "Challenge 2: Logic Puzzle",
        description: "If there are 3 apples and you take away 2, how many do you have?",
        answer: "2",
        points: 15
    },
    {
        title: "Challenge 3: Pattern Recognition",
        description: "Complete the sequence: 2, 4, 8, 16, __?",
        answer: "32",
        points: 20
    },
    {
        title: "Challenge 4: Basic Coding",
        description: "In modern JavaScript (ES6+), what is the recommended keyword to declare a block-scoped variable? (hint: 3 letters)",
        answer: "let",
        points: 25
    },
    {
        title: "Challenge 5: Algorithm Thinking",
        description: "What is the result of 3 * (4 + 2)?",
        answer: "18",
        points: 30
    }
];

// Level progression configuration
const levelThresholds = [0, 50, 100, 150];

function checkAnswer() {
    const userAnswer = document.getElementById('answer').value.trim().toLowerCase();
    const feedback = document.getElementById('feedback');
    const correctAnswer = challenges[currentChallenge].answer.toLowerCase();
    
    if (userAnswer === correctAnswer) {
        feedback.style.color = "#66fcf1";
        const earnedPoints = challenges[currentChallenge].points;
        totalPoints += earnedPoints;
        galaxiesUnlocked++;
        
        // Update level based on thresholds
        for (let i = levelThresholds.length - 1; i >= 0; i--) {
            if (totalPoints >= levelThresholds[i]) {
                currentLevel = i + 1;
                break;
            }
        }
        
        feedback.textContent = `🎉 Correct! You earned ${earnedPoints} points and unlocked a new galaxy!`;
        document.getElementById('points').textContent = totalPoints;
        document.getElementById('galaxies').textContent = galaxiesUnlocked;
        document.getElementById('level').textContent = currentLevel;
        document.getElementById('next-btn').style.display = 'inline-block';
        document.getElementById('answer').disabled = true;
    } else {
        feedback.style.color = "#ff4d4d";
        feedback.textContent = "❌ Oops! Try again.";
    }
}

function nextChallenge() {
    currentChallenge++;
    if (currentChallenge >= challenges.length) {
        document.getElementById('game-container').innerHTML = `
            <h3 style="color: #66fcf1;">🏆 Congratulations!</h3>
            <p>You've completed all available challenges!</p>
            <p style="font-size: 1.2em; margin: 20px 0;">Final Score: ${totalPoints} points</p>
            <p>More challenges coming soon. Keep exploring the galaxy!</p>
        `;
        return;
    }
    
    const challenge = challenges[currentChallenge];
    document.getElementById('challenge-title').textContent = challenge.title;
    document.getElementById('challenge-description').textContent = challenge.description;
    document.getElementById('answer').value = '';
    document.getElementById('answer').disabled = false;
    document.getElementById('feedback').textContent = '';
    document.getElementById('next-btn').style.display = 'none';
}

// Initialize game when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Set up event listeners
    const answerInput = document.getElementById('answer');
    
    // Allow Enter key to submit answer
    if (answerInput) {
        answerInput.addEventListener('keypress', function(event) {
            if (event.key === 'Enter' && !this.disabled) {
                checkAnswer();
            }
        });
    }
});
