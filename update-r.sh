#!/bin/bash
#
# This will update R from 3.4 to 3.6
#
# Ty Mees (T.D.Mees@uu.nl) 2019-12-03

set -e

_apt_deb_file="/etc/apt/sources.list.d/R-CRAN.list"

warn () {
    echo "$@" >&2
}
die () {
    rc=$1
    shift
    warn "$@"
    exit $rc
}

if [ "$(id -u)" != "0" ]; then
  warn "This script must be run as root."
  exit 1
fi

if grep -q "xenial-cran35" $_apt_deb_file
then
    echo "Apt file looks okay"
else
    warn "Apt file does not have the correct debian repository, trying to fix..."
    sed -i 's/xenial/xenial-cran35/g' $_apt_deb_file

    if grep -q "xenial-cran35" $_apt_deb_file
    then
        echo "Apt file looks okay now"
        warn "Please make sure Puppet was configured to use the new debian repository!"
    else
        die 1 "Apt file still does not have the correct debian repository, exiting..."
    fi
fi

echo "Removing R"
apt remove r-base-dev -y #&> /tmp/update-r-remove-step.log
echo "Removing leftover R dependencies"
apt autoremove -y #&> /tmp/update-r-remove-dependencies-step.log

echo "Deleting possible leftover R libraries"
rm -rf /usr/local/lib/R/site-library
rm -rf /usr/lib/R/site-library
rm -rf /usr/lib/R/library

echo "Updating Apt"
apt update #&> /tmp/update-r-update-apt-step.log

echo "Installing R related dependencies"
apt install libcurl4-openssl-dev libxml2-dev -y #&> /tmp/update-r-install-dependencies-step.log

echo "Installing R"
apt install r-base-dev -y #&> /tmp/update-r-install-R-step.log

echo "Installing R packages provided by Apt"
apt install r-cran-lattice r-cran-matrix -y #&> /tmp/update-r-install-R-apt-packages-step.log

echo "Installing R packages from CRAN"

echo "Installing 'car'"
R -e "install.packages('car', repos='https://cran.rstudio.com', lib='/usr/lib/R/library', Ncpus = 4)" #&> /tmp/update-r-install-R-car-step.log

echo "Installing 'ggplot2'"
R -e "install.packages('ggplot2', repos='https://cran.rstudio.com', lib='/usr/lib/R/library', Ncpus = 4)" #&> /tmp/update-r-install-R-ggplot2-step.log

echo "Installing 'lsmeans'"
R -e "install.packages('lsmeans', repos='https://cran.rstudio.com', lib='/usr/lib/R/library', Ncpus = 4)" #&> /tmp/update-r-install-R-lsmeans-step.log

echo "Installing 'devtools'"
R -e "install.packages('devtools', repos='https://cran.rstudio.com', lib='/usr/lib/R/library', Ncpus = 4)" #&> /tmp/update-r-install-R-devtools-step.log

echo "Installing 'doBy'"
R -e "install.packages('doBy', repos='https://cran.rstudio.com', lib='/usr/lib/R/library', Ncpus = 4)" #&> /tmp/update-r-install-R-doBy-step.log

echo "Installing 'eyetrackingR'"
R -e "devtools::install_github(\"jwdink/eyetrackingR\")" #&> /tmp/update-r-install-R-eyetrackingR-step.log
