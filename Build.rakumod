# Put this file in the top level of the module's repo directory
class Build {
    # $dist-path is: repo dir
    method build($dist-path) {
        my $bfile = "cw-gen-config";
        my $script = $dist-path.IO.add("sbin/$bfile").absolute;

        # We need to set this if our script uses any dependencies that
        # may not yet be installed but are in the process of being
        # installed (such as the dist this comes with in lib/).
        my @libs = "$dist-path", $*REPO.repo-chain.map(*.path-spec).flat;

        # do it (note additional args after the executable $script!
        my $proc = run :cwd($dist-path), 
                   $*EXECUTABLE, @libs.map({"-I$_"}).flat, $script, "build";
        exit $proc.exitcode;
    }
}
