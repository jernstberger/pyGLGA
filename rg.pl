#!/usr/bin/perl

use Math::Random;
use strict;

process_options2();

sub print_usage {
print<<EOF;
SYNOPSIS
	rg.pl -t [type] -n num [-m num] [-k num] [-p true|false] [-t2 type -n2 num [-m2 num] [-k2 num]]

DESCRIPTION
	-p true|false
		Product graph. Specifiy -t, -n, -m, -k for first graph and -t2, -n2, -m2, -mk for second graph.

	type =	k	(n): complete graph
	       	c	(n): cycle
		p	(n): path
		t	(n): random tree
		w	(n): wheel
		s	(n): star
		r	(n): normal random caterpillar
		r2	(n): uniform random caterpillar
		kmn	(m, n): complete bipartite graph
		cr	(n): crown
		h	(n): helm
		gp	(n, k): generalized Petersen graph

EOF
}

sub process_options2 {
	my %args = ();
	my $graph_ref;

	if (scalar(@ARGV) < 2) {
		print_usage();
		exit;
	}
	else {
		for (my $i = 0; $i < scalar(@ARGV); $i += 2) {
			if ($i < scalar(@ARGV) - 1) {
				$args{$ARGV[$i]} = $ARGV[$i+1];
			}
		}
	}


	if ($args{"-t"} eq "k") {
		$graph_ref = complete($args{"-n"});
	}
	elsif ($args{"-t"} eq "c") {
		$graph_ref = cycle($args{"-n"});
	}
	elsif ($args{"-t"} eq "p") {
		$graph_ref = path($args{"-n"});
	}
	elsif ($args{"-t"} eq "t") {
		$graph_ref = random_tree($args{"-n"});
	}
	elsif ($args{"-t"} eq "w") {
		$graph_ref = wheel($args{"-n"});
	}
	elsif ($args{"-t"} eq "s") {
		$graph_ref = star($args{"-n"});
	}
	elsif ($args{"-t"} eq "r") {
		$graph_ref = random_pillar($args{"-n"});
	}
	elsif ($args{"-t"} eq "r2") {
		$graph_ref = random_pillar2($args{"-n"});
	}
	elsif ($args{"-t"} eq "kmn") {
		$graph_ref = complete_bipartite($args{"-m"}, $args{"-n"});
	}
	elsif ($args{"-t"} eq "cr") {
		$graph_ref = crown($args{"-n"});
	}
	elsif ($args{"-t"} eq "h") {
		$graph_ref = helm($args{"-n"});
	}
	elsif ($args{"-t"} eq "gp") {
		$graph_ref = gp($args{"-n"}, $args{"-k"});
	}

	if ($args{"-p"} eq "true") {
		my $graph2_ref;

		if ($args{"-t"} eq "k") {
			$graph2_ref = complete($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "c") {
			$graph2_ref = cycle($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "p") {
			$graph2_ref = path($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "t") {
			$graph2_ref = random_tree($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "w") {
			$graph2_ref = wheel($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "s") {
			$graph2_ref = star($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "r") {
			$graph2_ref = random_pillar($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "r2") {
			$graph2_ref = random_pillar2($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "kmn") {
			$graph2_ref = complete_bipartite($args{"-m2"}, $args{"-n2"});
		}
		elsif ($args{"-t2"} eq "cr") {
			$graph2_ref = crown($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "h") {
			$graph2_ref = helm($args{"-n2"});
		}
		elsif ($args{"-t2"} eq "gp") {
			$graph2_ref = gp($args{"-n2"}, $args{"-k2"});
		}

		my $product_ref = product($graph_ref, $graph2_ref);
		print_graph($product_ref);
	}
	else {
		print_graph($graph_ref);
	}

}

sub print_graph {
	my ($graph_ref, $filename) = @_;

	my @graph = @{$graph_ref};
	my %vertices = %{$graph[0]};
	my @edges = @{$graph[1]};
	my $n = scalar(keys %vertices);
	my $e = scalar(@edges);
	print "$n\t$e\n";

	for (my $i = 0; $i < scalar(@edges); $i++) {
		my @edge = @{$edges[$i]};
		my @edge = sort{$a <=> $b} @edge;
		print "$edge[0]\t$edge[1]\n";
	}

}

sub complete_bipartite {
	my ($m, $n) = @_;

	my %vertices = ();
	my @edges = ();

	for (my $i = 1; $i <= $m; $i++) {
		$vertices{$i} = 1;
		for (my $j = $m + 1; $j <= $m + $n; $j++) {
			$vertices{$j} = 1;
			my @edge = ($i, $j);
			push (@edges, \@edge);
		}
	}

	my @graph = (\%vertices, \@edges);

	return \@graph;
}

sub gp {
	my ($n, $k) = @_;

	my $c_ref = cycle($n);
	my @c = @{$c_ref};
	my %vertices = %{$c[0]};
	my @edges = @{$c[1]};

	for (my $i = 0; $i < $n; $i++) {
		my $u = $i + 1;
		my $v = $n + $i + 1;
		$vertices{"$v"} = 1;
		my @edge = ($u, $v);
		push (@edges, \@edge);

	}

	for (my $i = 0; $i < $n; $i++) {
		my $u = $n + $i + 1;
		my $v = ($i + $k) % $n;
		$v = $v + $n + 1;
		my @edge = ($u, $v);
		push (@edges, \@edge);
	}

	my @graph = (\%vertices, \@edges);
	return \@graph;
}

sub crown {
	my $n = shift;

	my %vertices = ();
	my @edges = ();

	for (my $i = 1; $i <= $n; $i++) {
		$vertices{$i} = 1;
		for (my $j = 1; $j <= $n; $j++) {
			if ($i != $j) {
				my $u = $n + $j;
				$vertices{$u} = 1;
				my @edge = ($i, $u);
				push (@edges, \@edge);
			}
		}
	}

	my @graph = (\%vertices, \@edges);
	return \@graph;
}

sub helm {
	my $n = shift;

	my $w_ref = wheel($n);
	my @w = @{$w_ref};
	my %vertices = %{$w[0]};
	my @edges = @{$w[1]};

	for (my $i = 1; $i <= $n; $i++) {
		my $u = $n + $i;
		$vertices{"$u"} = 1;
		my @edge = ($i, $u);
		push (@edges, \@edge);
	}

	my @graph = (\%vertices, \@edges);
	return \@graph;
}

sub product {
	my ($g1_ref, $g2_ref) = @_;
	my @g1 = @{$g1_ref};
	my @g2 = @{$g2_ref};
	my %vertices1 = %{$g1[0]};
	my @edges1 = @{$g1[1]};
	my %vertices2 = %{$g2[0]};
	my @edges2 = @{$g2[1]};
	my %prevertices = ();
	my @preedges = ();
	my %vertices = ();
	my @edges = ();

	for (my $i = 0; $i < scalar(@edges1); $i++) {
		my $e1_ref = $edges1[$i];
		my @edge1 = @{$e1_ref};
		@edge1 = sort {$a <=> $b} @edge1;
		my $u = $edge1[0];
		my $v = $edge1[1];
		for (my $j = 0; $j < scalar(@edges2); $j++) {
			my $e2_ref = $edges2[$j];
			my @edge2 = @{$e2_ref};
			@edge2 = sort {$a <=> $b} @edge2;
			my $up = $edge2[0];
			my $vp = $edge2[1];

			my $p1 = "$u.$up";
			my $p2 = "$v.$vp";
			$prevertices{$p1} = 1;
			$prevertices{$p2} = 1;
			my @edge = ($p1, $p2);
			push (@preedges, \@edge);

		}
	}

	my $count = 1;
	for my $v (keys %prevertices) {
		$vertices{$v} = $count++;
	}

	for my $e (@preedges) {
		my @edge = @{$e};
		my @newedge = ($vertices{$edge[0]}, $vertices{$edge[1]});
		push (@edges, \@newedge);
	}

	my @graph = (\%vertices, \@edges);
	return \@graph;
}

sub star {
	my $n = shift;

	my %vertices = ();
	my @edges = ();

	my $u1 = 1;
	$vertices{"$u1"} = 1;

	for (my $i = 2; $i <= $n; $i++) {
		my @edge = ($u1, $i);
		$vertices{"$i"} = 1;
		push (@edges, \@edge);
	}

	my @graph = (\%vertices, \@edges);

	return \@graph;
}

sub wheel {
	my $n = shift;
	my $prev = -1;

	my %vertices = ();
	my @edges = ();

	my $u1 = 1;
	$vertices{"$u1"} = 1;

	for (my $i = 2; $i <= $n; $i++) {
		$vertices{$i} = 1;
		my @edge = ($u1, $i);
		push (@edges, \@edge);

		if ($prev > 0) {
			my @edge = ($prev, $i);
			push (@edges, \@edge);
		}

		$prev = $i;
	}

	my @edge = ("2", $n);
	push (@edges, \@edge);

	my @graph = (\%vertices, \@edges);

	return \@graph;
}

sub cycle {
	my $n = shift;
	my $prev = -1;

	my %vertices = ();
	my @edges = ();

	for (my $i = 1; $i <= $n; $i++) {
		
		$vertices{$i} = 1;

		if ($prev > 0) {
			my @edge = ($prev, $i);
			push (@edges, \@edge);
		}

		$prev = $i;
	}

	my @edge = ("1", $n);
	push (@edges, \@edge);

	my @graph = (\%vertices, \@edges);

	return \@graph;
}

sub path {
	my $n = shift;
	my $prev = -1;

	my %vertices = ();
	my @edges = ();

	for (my $i = 1; $i <= $n; $i++) {

		$vertices{$i} = 1;

		if ($prev > 0) {
			my @edge = ($prev, $i);
			push (@edges, \@edge);
		}

		$prev = $i;
	}

	my @graph = (\%vertices, \@edges);

	return \@graph;
}

sub complete {
	my $n = shift;
	my %vertices = ();
	my @edges = ();

	for (my $i = 1; $i < $n; $i++) {
		$vertices{$i} = 1;
		for (my $j = $i + 1; $j <= $n; $j++) {
			$vertices{$j} = 1;
			my @edge = ($i, $j);
			push (@edges, \@edge);
		}
	}

	my @graph = (\%vertices, \@edges);

	return \@graph;
}

sub random_pillar2 {
	my $n = shift;

	my $num_backbone = int(rand($n) + 1);
	my $backbone_ref = path($num_backbone);
	my @backbone = @{$backbone_ref};
	my %vertices = %{$backbone[0]};
	my %backbone = %{$backbone[0]};
	my @edges = @{$backbone[1]};
	my $available = $n - $num_backbone;
	my $count = $num_backbone + 1;

	while ($available > 0) {
		my $u = int(rand(scalar(keys %backbone))) + 1;
		my @edge = ($u, $count);
		push (@edges, \@edge);
		$vertices{$count} = 1;
		$available--;
		$count++;
	}

	my @graph = (\%vertices, \@edges);

	return \@graph;
}


sub random_pillar {
	my $n = shift;
	my %vertices = ();
	my %backbone = ();
	my %ends = ();;
	my @edges = ();
	my @queue = ();
	my $available = $n;
	my $count = 1;

	my $u1 = $count;
	$vertices{"$u1"} = 1;
	$backbone{"$u1"} = 1;
	$ends{"$u1"} = 1;
	$count++;
	
	my $u2 = $count;
	$vertices{"$u2"} = 1;
	$backbone{"$u2"} = 1;
	$ends{"$u2"} = 1;
	$count++;

	my @edge = ($u1, $u2);
	push (@edges, \@edge);
	$available -= 2;

	while ($available > 0) {
		@queue = keys %backbone;

		while (my $parent = shift @queue) {
			my $ran = rann(0, 100);
			if ($ran > $available) {
				$ran = $available;
			}
			$available -= $ran;
			for (my $i = 0; $i < $ran; $i++) {
				my $u2 = $count;
				if (($ends{$parent} == 1) && ($i == 0)) {
					push (@queue, "$u2");
					$backbone{"$u2"} = 1;
					$ends{"$u2"} = 1;
					delete($ends{$parent});
				}
				$vertices{"$u2"} = 1;
				my @edge = ($parent, $u2);
				push (@edges, \@edge);
				$count++;
			}
		}
	}

	my @graph = (\%vertices, \@edges);

	return \@graph;
}

sub random_tree {
	my $n = shift;
	my %vertices = ();
	my @edges = ();
	my @queue = ();
	my $available = $n;
	my $count = 1;

	my $u1 = $count;
	$vertices{"$u1"} = 1;
	$count++;
	
	my $u2 = $count;
	$vertices{"$u2"} = 1;
	$count++;

	my @edge = ($u1, $u2);
	push (@edges, \@edge);
	$available -= 2;

	while ($available > 0) {
		@queue = keys %vertices;

		while (my $parent = shift @queue) {
			my $ran = rann(0, 100);
			if ($ran > $available) {
				$ran = $available;
			}
			$available -= $ran;
			for (my $i = 0; $i < $ran; $i++) {
				my $u2 = $count;
				push (@queue, "$u2");
				$vertices{"$u2"} = 1;
				my @edge = ($parent, $u2);
				push (@edges, \@edge);
				$count++;
			}
		}
	}

	my @graph = (\%vertices, \@edges);

	return \@graph;
}

sub rann {
	my ($min, $max) = @_;
	my $deviations = 100;
	my $r = $min-1;

	while (($r < $min) || ($r > $max)) {
		$r = int(random_normal($min + ($max - $min) / 2.0, ($max - $min) / 2.0 / $deviations));
	}
	return $r;
}
