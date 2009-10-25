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
  {},

  container: function()
  {
    if(!this.container) this.createContainer();
    return this.container;
  },

  handleEvent: function(ev) {
    var name = ev.event;
    if(!name) return;
    var handler = Deception.events[name];
    if(handler) handler.call(this, ev);
  },
  
  showMessage: function(message, css_class) {
    var c = this.container();
    var entry = $("<li class='message'/>");
    entry.html(message).addClass(css_class).hide();
    entry.prependTo(c).slideDown();
  }

};

// Our basic event definitions
Deception.onEvent("period-change", function(data) {
  this.showMessage(data.message, "period-change");
});

Deception.onEvent("vote", function(data) {
  // TODO: Update vote
  this.showMessage(data.message, "vote");
});

Deception.onEvent("lynched", function(data) {
  this.showMessage(data.message, "lynched");
});

Deception.onEvent("attacked", function(data) {
  this.showMessage(data.message, "attacked");
});

Deception.onEvent("no-death", function(data) {
  this.showMessage(data.message, "no-death");
});

Deception.onEvent("game-ended", function(data) {
  this.endGame();
});

Deception.onEvent("game-started", function(data) {
  this.startGame();
});

Deception.onEvent("player-joined", function(data) {
});

Chainsaw.onLogMessage("deception:game-event", function(message, channel) {
  var game = Deception.gameFor(channel);
  if(game) {
    game.handleEvent(message);
  }
});