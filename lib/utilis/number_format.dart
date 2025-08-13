extension Abbreviation on double {
  double shorten() {
    if (this >= 1e12) {
      return this / 1e12; // trillions
    } else if (this >= 1e9) {
      return this / 1e9; // billions
    } else if (this >= 1e6) {
      return this / 1e6; // millions
    } else {
      return this; // no change
    }
  }
}
