Trobleshooting
gdk-pixbuf glycin err
fix:https://gitlab.archlinux.org/archlinux/packaging/packages/gdk-pixbuf2/-/commit/a38ed60625197687ef6981cea4d6bbb2f1b9668b
clone 
git checkout  a38ed60625197687ef6981cea4d6bbb2f1b9668b
nvim PKGBUILD
arch= any
build()
-D tests=false
