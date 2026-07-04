use strict;
use IO::Socket::INET;
use File::Basename;
use POSIX qw(WNOHANG);

my $root = dirname(__FILE__);
my $port = $ENV{PORT} || $ARGV[0] || 3000;

my %mime = (
    html => 'text/html; charset=utf-8',
    css  => 'text/css',
    js   => 'application/javascript',
    json => 'application/json',
    png  => 'image/png',
    jpg  => 'image/jpeg',
    svg  => 'image/svg+xml',
    ico  => 'image/x-icon',
    woff2=> 'font/woff2',
);

my $server = IO::Socket::INET->new(
    LocalPort => $port,
    Listen    => 10,
    ReuseAddr => 1,
    Proto     => 'tcp',
) or die "Cannot bind port $port: $!\n";

print "Serving $root on http://localhost:$port\n";
$| = 1;

while (my $client = $server->accept()) {
    my $pid = fork();
    if ($pid == 0) {
        my $req = <$client>;
        1 while <$client> =~ /\S/;
        my ($method, $path) = ($req =~ /^(\w+)\s+(\S+)/);
        $path =~ s/\?.*//;
        $path = '/' if $path eq '';
        $path = '/index.html' if $path eq '/';
        $path =~ s|/+|/|g;
        $path =~ s|\.\.||g;

        my $file = $root . $path;
        if (-f $file) {
            my ($ext) = ($file =~ /\.(\w+)$/);
            my $ct = $mime{lc($ext)} || 'application/octet-stream';
            open my $fh, '<:raw', $file or do {
                print $client "HTTP/1.0 403 Forbidden\r\n\r\n";
                close $client; exit;
            };
            local $/; my $body = <$fh>; close $fh;
            print $client "HTTP/1.0 200 OK\r\nContent-Type: $ct\r\nContent-Length: " . length($body) . "\r\n\r\n$body";
        } else {
            print $client "HTTP/1.0 404 Not Found\r\nContent-Type: text/plain\r\n\r\nNot found: $path\n";
        }
        close $client;
        exit 0;
    }
    close $client;
    waitpid(-1, WNOHANG);
}
