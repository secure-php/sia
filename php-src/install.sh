#./buildconf --force
./configure       \
        --with-apxs2=/usr/bin/apxs \
		--enable-cgi      \
		--enable-ftp      \
		--enable-mbstring \
		--with-gd         \
		--with-mysql      \
		--with-ssl      \
		--with-mysqli      \
		--with-pdo-mysql  \
		--with-zlib       \
        --with-zip  --enable-gd  --with-intl --enable-intl  --enable-openssl --with-openssl 
        
#--enable-debug --enable-phpdbg
        
sed -i '/EXTRA_INCLUDES =/c\EXTRA_INCLUDES = -I/home/phli/s2e-env/s2e/source/s2e/guest/common/include ' Makefile

make -j6
