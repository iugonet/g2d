require 'net/smtp'

class SP2DSpMail

 $smtp = "sknet1.stelab.nagoya-u.ac.jp"
 $port = 25
 $from = "kouno@stelab.nagoya-u.ac.jp"
 $to   = "z47878a@cc.nagoya-u.ac.jp"

 def initialize
 end

 def start()
   Net::SMTP.start( $smtp, $port ) { |smtp|
smtp.send_mail <<EndOfMail, $from, $to
From: kouno@stelab.nagoya-u.ac.jp
To: z47878a@cc.nagoya-u.ac.jp
Subject: spase2dspace start
spase2dspace start
EndOfMail
   }
 end

 def end()
  Net::SMTP.start( $smtp, $port ) { |smtp|
smtp.send_mail <<EndOfMail, $from, $to
From: kouno@stelab.nagoya-u.ac.jp
To: z47878a@cc.nagoya-u.ac.jp
Subject: spase2dspace end
spase2dspace end
EndOfMail
  }

 end

end
