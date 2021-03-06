ifndef STAGE2_MK
STAGE2_MK=stage2.mk

include init.mk

install/stage2: install/stage1 \
	install/_stage2-local_overlay \
	install/_stage2-workarounds \
	install/_stage2-sed \
	install/_stage2-bash \
	install/_stage2-xz-utils \
	install/_stage2-bzip2 \
	install/_stage2-gzip \
	install/_stage2-perl \
	install/_stage2-automake \
	install/_stage2-tar \
	install/_stage2-file \
	install/_stage2-pkgconfig \
	install/_stage2-wget \
	install/_stage2-baselayout-prefix \
	install/_stage2-m4 \
	install/_stage2-flex \
	install/_stage2-bison \
	install/_stage2-binutils-config \
	install/_stage2-binutils \
	install/stage2-gcc \
	install/stage2-up-to-pax-utils \
	install/stage2-portage
	touch $@
stage2: install/stage2

install/_stage2-local_overlay:
	# -- Add local overlay
	mkdir -p ${EPREFIX}/usr/local/portage
	rsync -avuz files/usr/local/portage/* ${EPREFIX}/usr/local/portage/
	cp -vf files/etc/make.conf.stage2 ${EPREFIX}/etc/make.conf
	echo "PORTDIR_OVERLAY='\$${PORTDIR_OVERLAY} ${EPREFIX}/usr/local/portage/'" >> ${EPREFIX}/etc/make.conf
	touch $@

install/_stage2-workarounds:
	# -- python-updater
	cp -vf files/etc/portage/package.keywords/python-updater.prefix \
		${EPREFIX}/etc/portage/package.keywords/python-updater.prefix
	touch $@

install/_stage2-sed:
	${EMERGE} --oneshot -j sys-apps/sed
	touch $@

install/_stage2-bash:
	MAKEOPTS=-j1 ${EMERGE} --oneshot --nodeps '=app-shells/bash-4.1*'
	touch $@

install/_stage2-xz-utils:
	${EMERGE} --oneshot --nodeps app-arch/xz-utils
	touch $@

install/_stage2-gzip:
	${EMERGE} --oneshot --nodeps sys-libs/gzip
	touch $@

install/_stage2-bzip2:
	${EMERGE} --oneshot --nodeps app-arch/bzip2
	touch $@

install/_stage2-perl:
	cp -vf files/etc/portage/package.keywords/perl.prefix \
		${EPREFIX}/etc/portage/package.keywords/perl.prefix
	cp -vf files/etc/portage/package.mask/perl.prefix \
		${EPREFIX}/etc/portage/package.mask/perl.prefix
ifeq (${UBUNTU_11_12},true)
	${EMERGE} --oneshot --nodeps app-admin/perl-cleaner
	ebuild files/usr/local/portage/dev-lang/perl/perl-5.12.4-r99.ebuild clean merge < /dev/null
else
	${EMERGE} --oneshot -u -j dev-lang/perl < /dev/null
endif
	touch $@

install/_stage2-automake:
	${EMERGE} --oneshot -u -j sys-apps/help2man
	${EMERGE} --oneshot -u -j sys-devel/automake
	touch $@

install/_stage2-tar:
	${EMERGE} --oneshot --nodeps '=app-arch/tar-1.26'
	touch $@

install/_stage2-file:
	${EMERGE} --oneshot --nodeps sys-apps/file
	touch $@

install/_stage2-pkgconfig:
	ACCEPT_KEYWORDS='**' emerge -q --oneshot -u -j '=dev-libs/libelf-0.8.13*'
	PKG_CONFIG_PATH=${EPREFIX}/usr/lib/pkgconfig ${EMERGE} --oneshot -u -j dev-util/pkgconfig
	touch $@

install/_stage2-wget:
	${EMERGE} --oneshot -u -j net-misc/wget
	touch $@

install/_stage2-baselayout-prefix:
	${EMERGE} --oneshot --nodeps sys-apps/baselayout-prefix
	touch $@

install/_stage2-m4:
	${EMERGE} --oneshot --nodeps sys-devel/m4
	touch $@

install/_stage2-flex:
	${EMERGE} --oneshot --nodeps sys-devel/flex
	touch $@

install/_stage2-bison:
	${EMERGE} --oneshot --nodeps sys-devel/bison
	touch $@

install/stage2-up-to-bison: install/stage1 \
	touch $@

install/_stage2-binutils-config:
	# emerge --oneshot --nodeps "<sys-devel/binutils-2.22"
	${EMERGE} --oneshot --nodeps sys-devel/binutils-config
	touch $@

install/_stage2-binutils: install/_stage2-binutils-config
ifeq (${UBUNTU_11_12},true)
	mkdir -p ${EPREFIX}/usr/local/portage/sys-devel/binutils
	rsync -avuz files/usr/local/portage/sys-devel/binutils/* ${EPREFIX}/usr/local/portage/sys-devel/binutils/
	rm -vf ${EPREFIX}/usr/local/portage/sys-devel/binutils/binutils-2.1*
	ebuild ${EPREFIX}/usr/local/portage/sys-devel/binutils/binutils-2.22-r99.ebuild digest
	MAKEOPTS=-j1 ${EMERGE} --oneshot --nodeps sys-devel/binutils
else
	MAKEOPTS=-j1 ${EMERGE} --oneshot --nodeps sys-devel/binutils \
		|| \
		MAKEOPTS=-j1 ebuild --skip-manifest \
		${EPREFIX}/usr/local/portage/sys-devel/binutils/binutils-2.20.1-r1.ebuild \
		clean merge
endif
	touch $@

install/stage2-gcc: install/_stage2-binutils
	${EMERGE} --oneshot --nodeps -u sys-devel/gcc-config
	# XXX: get the right kernel version?
	${EMERGE} --oneshot --nodeps -u sys-kernel/linux-headers
	${EMERGE} --oneshot -u -j sys-devel/bison
	${EMERGE} --nodeps "=sys-devel/gcc-4.2*"
	echo ">=sys-devel/gcc-4.2" > ${EPREFIX}/etc/portage/package.mask/gcc
	echo "<sys-devel/gcc-4.2" > ${EPREFIX}/etc/portage/package.mask/gcc
	touch $@

install/stage2-up-to-pax-utils: install/stage2-gcc
	${EMERGE} --oneshot -u coreutils
ifeq (${UBUNTU_11_12},true)
	mkdir -p ${EPREFIX}/usr/local/portage/dev-lang/perl
	rsync -avuz files/usr/local/portage/dev-lang/perl/* ${EPREFIX}/usr/local/portage/dev-lang/perl/
	ebuild ${EPREFIX}/usr/local/portage/dev-lang/perl/perl-5.12.4-r99.ebuild digest
endif
	# perl workaround to avoid user confirmation
	${EMERGE} --oneshot -u -j dev-lang/perl < /dev/null
	${EMERGE} --oneshot -u -j findutils
	${EMERGE} --oneshot -u -j sys-devel/automake
	${EMERGE} --oneshot -u -j app-arch/tar
	${EMERGE} --oneshot -u -j sys-apps/grep
	${EMERGE} --oneshot -u -j sys-devel/patch
	${EMERGE} --oneshot -u -j sys-apps/gawk
	${EMERGE} --oneshot -u -j sys-devel/make
	${EMERGE} --oneshot --nodeps -u sys-apps/file
	${EMERGE} --oneshot --nodeps -u app-admin/eselect
	${EMERGE} --oneshot -u -j app-misc/pax-utils
	touch $@

install/stage2-portage-workarounds: install/stage2-up-to-pax-utils
	# -- python: workarounds (only for stage2)
	${EMERGE} --oneshot -u -j sys-libs/readline
	ebuild ${EPREFIX}/usr/local/portage/app-admin/python-updater/python-updater-0.10-r2.ebuild digest
	${EMERGE} --oneshot --nodeps -u app-admin/python-updater
	FEATURES=-collision-protect ${EMERGE} --oneshot --nodeps -u app-admin/eselect-python
	USE=-xml ${EMERGE} --nodeps -u -j dev-lang/python
	eselect python set python2.7
	touch $@

install/stage2-portage: install/stage2-up-to-pax-utils install/stage2-portage-workarounds
	# -- Update portage
	env FEATURES="-collision-protect" ${EMERGE} --oneshot sys-apps/portage
	# -- Move tmp directory
	mv -f ${EPREFIX}/tmp ${EPREFIX}/tmp.old
	## -- Add local overlay
	#mkdir -p ${EPREFIX}/usr/local/portage/
	#rsync -avuz files/usr/local/portage/* ${EPREFIX}/usr/local/portage/
	#echo "PORTDIR_OVERLAY=\"\${PORTDIR_OVERLAY} ${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	# -- Synchronize repo
	${EMERGE} --sync
	touch $@

endif
