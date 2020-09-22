class WeddingStatistic {
  int allGuests, attendedGuests, scannedGuests;

  WeddingStatistic({
    this.allGuests,
    this.attendedGuests,
    this.scannedGuests,
  });

  WeddingStatistic.fromResponse(Map<String, dynamic> response) {
    if (response.containsKey('all_guests')) allGuests = response['all_guests'];

    if (response.containsKey('attended_guests'))
      attendedGuests = response['attended_guests'];

    if (response.containsKey('scanned_guests'))
      scannedGuests = response['scanned_guests'];

    if (allGuests == null) allGuests = 0;
    if (attendedGuests == null) attendedGuests = 0;
    if (scannedGuests == null) scannedGuests = 0;
  }
}
