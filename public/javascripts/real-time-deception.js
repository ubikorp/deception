// real-time-deception.js - Adds realtime update support to deception.

Deception = function(game) {
  Deception.last = this;
  this.game_id = game;
  Deception.games[game.toString()] = this;
  Chainsaw.watchLogs("deception:game:" + game);
};

Deception.last = null;
Deceptions.games = {};

Deception.events = {};
Deception.onEvent = function(name, f) {
  Deception.events[name] = f;
};

Deception.gameFor = function(channel) {
  var parts = channel.split(":");
  return Deception.games[parts[parts.length - 1]];
};

Deception.prototype = {
  game_id: null,
  currentDay: 1,
  currentPeriod: "day",
  numberOfDays: 14,
  currentVotes: {},

  receiveComment: function(comment)
  {},

  updateVote: function(from_user, for_user)
  {},

  nextPeriod: function()
  {
    if(this.currentPeriod == "night") {
      this.currentPeriod = "day";
    } else {
      this.currentPeriod = "night";
      this.currentDay++;
    }
    // End the game when we're over the limit of days.
    if(this.currentDay > this.numberOfDays) {
      this.endGame();
    } else {
      this.createContainer();
    }
  },

  endGame: function()
  {},

  startGame: function()
  {},

  updateRoundStatus: function(status)
  {},

  createContainer: function()
  {
  },

  container: function()
  {
    if(!this.container) this.createContainer();
    return this.container;
  },

  handleEvent: function(ev) {
  }

};

// Our basic event definitions.
Deception.onEvent("period-change", function(c, t) {
});

Deception.onEvent("vote", function(c, t) {
});

Deception.onEvent("lynched", function(c, t) {
});

Deception.onEvent("attacked", function(c, t) {
});

Deception.onEvent("no-death", function(c, t) {
});

Deception.onEvent("game-ended", function(c, t) {
});

Deception.onEvent("game-started", function(c, t) {
});

Deception.onEvent("played-joined", function(c, t) {
});

Chainsaw.onLogMessage("deception:game-event", function(message, channel) {
  var game = Deception.gameFor(channel);
  if(game) {
    game.handleEvent(message);
  }
});