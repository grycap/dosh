%define version %(cat ../../src/version | awk -F'-' '{print $1}')
%define revision %(cat ../../src/version | awk -F'-' '{print $2}')

Summary:        DoSH - Docker SHell
License:        Apache 2.0
Name:           dosh
Version:        %{version}
Release:        %{revision}
Group:          System Environment/Shells
URL:            https://github.com/grycap/dosh
Packager:       Carlos A. <caralla@upv.es>
Requires:       bash, sudo, gettext, coreutils, glibc-common
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

%description 
 Use Docker containers to run the shell of the users in your Linux system.
 DoSH provides a configurable and secure mechanism to make that when a user 
 logs-in a Linux system, a customized (or standard) container will be created
 for him. This will enable to limit the resources that the user is able to 
 use, the applications, etc. but also provide custom linux flavour for each 
 user or group of users.
 
%prep
%setup -q
%build

%install
mkdir -p $RPM_BUILD_ROOT/etc/dosh/scripts
mkdir -p $RPM_BUILD_ROOT/etc/dosh/conf.d
mkdir -p $RPM_BUILD_ROOT/etc/sudoers.d
mkdir -p $RPM_BUILD_ROOT/bin/
mkdir -p $RPM_BUILD_ROOT/var/log
install -m 0600 -d $RPM_BUILD_ROOT/etc/dosh/scripts
install -m 0600 -d $RPM_BUILD_ROOT/etc/dosh/conf.d
install -m 0600 etc/dosh.conf $RPM_BUILD_ROOT/etc
install -m 0600 etc/dosh.sudoers $RPM_BUILD_ROOT/etc/sudoers.d/dosh
install -m 0755 bin/dosh $RPM_BUILD_ROOT/bin
install -m 0755 bin/shell2docker $RPM_BUILD_ROOT/bin

%post
if [ ! -f /var/log/dosh.log ]; then
  touch /var/log/dosh.log
  chown root:root /var/log/dosh.log
  chmod 600 /var/log/dosh.log
fi
if [ -e /etc/shells ]; then
  sed -i '/^\/bin\/dosh$/d' /etc/shells
fi
echo '/bin/dosh' >> /etc/shells

%postun
if [ -e /etc/shells ]; then
  sed -i '/^\/bin\/dosh$/d' /etc/shells
fi

%files
%defattr(-,root,root,700)
/bin/dosh
/bin/shell2docker
%config(noreplace) /etc/dosh/scripts
%config(noreplace) /etc/dosh/conf.d
%config(noreplace) /etc/dosh.conf
%config(noreplace) /etc/sudoers.d/dosh