#!/usr/bin/perl
use CGI::Session;
use CGI;

$query = new CGI;
print $query->header;
$cookie = $query->cookie(-name => "session");
if ($cookie) {
  CGI::Session->name($cookie);
}
$session = new CGI::Session("driver:File",$cookie,{'Directory'=>"/tmp/apache"}) or die "$!";
$status = $session->param('status');
print $status;

