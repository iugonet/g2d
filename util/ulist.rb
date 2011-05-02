require 'date'
require 'fileutils'

BASE_URL="http://search.iugonet.org"

IUGONET_DIR="/opt/dspace/webapps/iugonet"

t = DateTime.now
ts = t.strftime( "%Y-%m-%dT%H:%M:%S%z" )
ufile = "update_" + ts + ".out"
tfile = IUGONET_DIR + "/iugonet/" + ufile
FileUtils.cp( "update.out", ufile )
FileUtils.cp( "update.out", tfile )

def getSize( name, type )
  key = "--- " + type + " ---";
  ln = 0
  f = false
  fr = open( name, "r" )
  fr.each { |line|
    if line.include?( key )
      ln = 0
      f = true
    elsif line.include?("------")
      f = false
    elsif f == true
      ln = ln + 1
    end
  }
  fr.close

  return ln
end

fw = open("update_list.html","w")
fw.puts "<html>"
fw.puts "<head></head>"
fw.puts "<body>"

fw.puts "<table border=4 width=250>"
fw.puts "<caption>Update</caption>"
fw.puts "<tr>"
fw.puts "<th>date</th>"
fw.puts "<th>size[Byte]</th>"
fw.puts "<th>add</th>"
fw.puts "<th>replace</th>"
fw.puts "<th>delete</th>"
fw.puts "</tr>"

Dir.glob("/opt/dspace/webapps/iugonet/iugonet/update_*.out").sort.reverse.each {|name|
 puts name
 la = getSize( name, "Add" )
 lr = getSize( name, "Replace" )
 ld = getSize( name, "Delete" )
 bn = File.basename(name)
 bndate = File.basename(name,".out")
 bndate[0..6] = ""
 s = File.size(name)
 ss = ""
 if s.to_i < 1e3
   ss = (s.to_i).to_s
 elsif s.to_i < 1e6
   ss = ((s/1e3).to_i).to_s + "K"
 elsif s.to_i < 1e9
   ss = ((s/1e6).to_i).to_s + "M"
 end
 fw.puts "<tr>"
 fw.puts "<td><a href=\"" + BASE_URL + "/iugonet/iugonet/" +
         bn + "\">" + bndate + "</a></td>"
 fw.puts "<td align=\"center\">" + ss + "</td>"
 fw.puts "<td align=\"right\">" + la.to_s + "</td>"
 fw.puts "<td align=\"right\">" + lr.to_s + "</td>"
 fw.puts "<td align=\"right\">" + ld.to_s + "</td>"
 fw.puts "</tr>"
}
fw.puts "</table>"

fw.puts "</body>"
fw.puts "</html>"

fw.close

