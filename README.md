FeedParse2Anywhere
==================

各種フィード（Google Reader、はてなブックマーク）を取得し、メールで送信する。
主にEvernoteやTumblrにメール送信することを想定してます。

Usage
-----
> $ perl fp2a.pl --kind  (grs|hb) --id <userid> --password <password>
   --kind (grs|hb)      GoogleReaderStarred(grs) or HatenaBookmark(hb)
   --id userid          Google or Hatena User ID
   --password password  Google Password(only GoogleReaderStarred)
   --file filename      Last ID file
   --label label        Last ID's Label(ex. 'lastid-grs:' or 'lastid-hb')
   --to email-address   Destination Address(an specify multiple is ok)
   --from email-address Source Address
   --tags tag           Tag Name
   --help               Show this message.
   --debug              Debug mode
