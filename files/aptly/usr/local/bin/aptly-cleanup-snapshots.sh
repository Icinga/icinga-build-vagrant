#!/bin/bash -xe
for repo in `aptly repo list --raw=true`; do
  case "$repo" in
    *-release)
      continue
      ;;
  esac

  dup=false
  for p in `aptly repo search $repo "Architecture" | sort -V`; do
    pkg=`echo $p | sed 's,_.*,,'`
    if test "$pkg" = "$pkg_old"; then
        dup=true
    elif $dup; then
        dup=false
        # $p_old is latest version of some package with more than one version
        # Output a search spec for all versions older than this
        # Version is 2nd field in output of aptly repo search, separated by _
        v_old=`echo $p_old | cut -d_ -f2`
        aptly repo remove $repo "$pkg_old (<< $v_old)"
    fi
    p_old="$p"
    pkg_old="$pkg"
  done
done

IFS=$'\n'
for publish in `aptly publish list --raw`; do
  IFS=' '
  set -- $publish
  aptly publish update $2 $1 || echo "Could not update publish: $publish"
done

aptly db cleanup
