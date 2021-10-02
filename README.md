# Nomics Client

## Questions and Notes

Providing an invalid currency to convert param on list method can lead to issues.
For example when you ask for the price in BTD (instead of BTC) accidentally, then you'll have the price returned as 0.0.
(assuming there's no BTD currency).