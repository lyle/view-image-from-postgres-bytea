This is a sinatra app that pulls some content from postgres.
Notably it uses "PGconn.unescape_bytea" to compensate for Postgres's 
greedy *escape_bytea* which causes no end of pain.

