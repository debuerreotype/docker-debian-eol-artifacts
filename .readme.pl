#!/usr/bin/env perl
use Mojo::Base -strict;

use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new;

# https://salsa.debian.org/publicity-team/debian-history/-/blob/master/project-history.en.dbk (`<chapter id="releases">`)
my $tx = $ua->get('https://salsa.debian.org/publicity-team/debian-history/-/raw/master/project-history.en.dbk');
die $tx->error if $tx->error;

my $dom = $tx->res->dom->find('chapter#releases')->first;
die 'missing "releases" chapter' unless $dom;

my $match = qr!^\s*Debian\s+([0-9.]+)\s+!s;

print <<'EOH';
# Debian EOL

This repository contains tags for [Debian releases](https://www.debian.org/releases/) which are [now End of Life](https://wiki.debian.org/DebianReleases#Production_Releases), and thus are available from [archive.debian.org](http://archive.debian.org).

Blurbs about each release listed below are from [the `debian-history` package](https://packages.debian.org/sid/debian-history), whose content [is also available online](https://www.debian.org/doc/manuals/project-history/releases.en.html).

Image contents are generated reproducibly via [the `debuerreotype` tool](https://github.com/debuerreotype/debuerreotype) (also used for [the `debian` official image](https://hub.docker.com/_/debian)), and the exact scripts and rootfs tarballs can be found in [github.com/debuerreotype/docker-debian-eol-artifacts](https://github.com/debuerreotype/docker-debian-eol-artifacts) (see especially the `dist-*` branches, such as [`dist-potato`'s `potato` directory](https://github.com/debuerreotype/docker-debian-eol-artifacts/tree/dist-potato/potato)).

Issues? https://github.com/debuerreotype/docker-debian-eol-artifacts/issues
EOH

sub _para_to_markdown {
	my $el = shift;

	$el->find('emphasis')->each(sub { $_->replace('*' . $_->content . '*') });

	$el->find('ulink')->each(sub { $_->replace('[' . $_->content . '](' . $_->attr('url') . ')') });

	$el->find('footnote')->map('remove');

	my $children = $el->children;
	if (@$children) {
		die "missed children:\n" . $children->map('to_string')->join("\n");
	}

	my $text = $el->text;
	$text =~ s/^\s+//;
	$text =~ s/\s+$//;
	$text =~ s/\n/ /g;
	return $text;
}

for my $suite (@ARGV) {
	my $debianVersion;
	my $el = $dom->find('para')->first(sub { ($debianVersion) = $_->content =~ m!$match<emphasis>\Q$suite\E</emphasis>\s+!is });
	die "missing $suite" unless $el;
	say "\n" . "## `debian/eol:$suite`";
	say "\n> " . _para_to_markdown($el);
	my $foundNext = 0;
	my $debianVersionMatch = qr!^\s*Debian\s+\Q$debianVersion\E\s+!s;
	$el->following('para')->grep(sub { !($foundNext ||= ($_->content =~ $match and $_->content !~ $debianVersionMatch)) })->each(sub {
		say ">\n> " . _para_to_markdown($_);
	});
}
