#!/bin/bash
echo "$(date)- Starting Daily Script" >> /home/arjun/2.1/cement/script/daily_report.txt

/usr/share/rvm/wrappers/ruby-2.3.8@nct/ruby  /home/arjun/2.1/cement/script/balancecheck.rb   >> /home/arjun/2.1/cement/script/daily_report.txt
echo "$(date)- Ending  Daily Script" >> /home/arjun/2.1/cement/script/daily_report.txt
