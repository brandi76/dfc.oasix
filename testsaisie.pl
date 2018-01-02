#!/usr/bin/perl    
use CGI;    
$html=new CGI; 

$param = $html->param('param');


print $html->header;    
print "<form>";
print "<input type=text name=param>";
print "<input type=submit></form>";
if (&valideMail($param)){
	print "valide";}
	else{
	print "non valide";
	}
sub valideMail {
	my ($mail)=@_;
	$mail=~ s/\.\@/\@/;
	if ($mail eq '') { return(0);}
	if ($mail!~ /\@/) { return(0);}
	if ($mail=~ /\@.*\@/) { return(0);}
	if ($mail=~ /[\,|\s|\;]/) {return (0)};
	if ($mail =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/ || ($mail !~ /^.+\@localhost$/ && $mail !~ /^.+\@\[?(\w|[-.])+\.[a-zA-Z]{2,3}|[0-9]{1,3}\]?$/)) {
    		return(0);
  	} else {
    	return(1);
  	}	
}

