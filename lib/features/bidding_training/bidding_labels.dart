import '../../scenarios/bidding_scenario.dart';

extension TrumpLabel on Trump {
  String get label => switch (this) {
    Trump.clubs => 'Clubs',
    Trump.diamonds => 'Diamonds',
    Trump.hearts => 'Hearts',
    Trump.spades => 'Spades',
    Trump.noTrump => 'Sans',
  };
}

extension DecisionLabel on BiddingDecision {
  String get label => switch (action) {
    BiddingAction.dash => 'Dash · 0 tricks',
    BiddingAction.enter => 'Enter bidding',
    BiddingAction.bid => '$tricks ${trump!.label}',
  };
}

extension RatingLabel on DecisionRating {
  String get label => switch (this) {
    DecisionRating.strong => 'Strong decision',
    DecisionRating.reasonable => 'Reasonable',
    DecisionRating.risky => 'Risky',
    DecisionRating.weak => 'Weak decision',
  };
}

String seatLabel(PlayerSeat seat) =>
    '${seat.name[0].toUpperCase()}${seat.name.substring(1)}';
