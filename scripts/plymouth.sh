#!/bin/bash
# Plymouth boot splash theme setup (omarchy-inspired)
set -euo pipefail

echo "Setting up Plymouth boot splash..."

# Create theme directory
echo "Creating Plymouth theme directory..."
sudo mkdir -p /usr/share/plymouth/themes/workstation

# Create Plymouth theme configuration
echo "Creating Plymouth theme configuration..."
sudo tee /usr/share/plymouth/themes/workstation/workstation.plymouth > /dev/null << 'EOF'
[Plymouth Theme]
Name=Workstation
Description=Workstation boot splash (omarchy-inspired)
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/workstation
ScriptFile=/usr/share/plymouth/themes/workstation/workstation.script
ConsoleLogBackgroundColor=0x1f2335
MonospaceFont=Cantarell 11
Font=Cantarell 11
EOF

# Create Plymouth script
echo "Creating Plymouth script..."
sudo tee /usr/share/plymouth/themes/workstation/workstation.script > /dev/null << 'EOF'
# Workstation Plymouth Theme (omarchy-inspired with Tokyo Night colors)

Window.SetBackgroundTopColor(0.094, 0.094, 0.125);
Window.SetBackgroundBottomColor(0.094, 0.094, 0.125);

# Create simple Arch logo if logo.png doesn't exist
if (Image("logo.png").GetWidth() == 0) {
    # Create a simple circle as logo placeholder
    logo.image = Image.Text("⬢", 1, 1, 1, 1, "Sans 48");
} else {
    logo.image = Image("logo.png");
}

logo.sprite = Sprite(logo.image);
logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2);
logo.sprite.SetOpacity(1);

# Progress bar setup
progress_box.image = Image("progress_box.png");
if (progress_box.image.GetWidth() == 0) {
    progress_box.image = Image.Text("", 0.3, 0.3, 0.3, 1, "Sans 1");
}

progress_box.sprite = Sprite(progress_box.image);
progress_box.sprite.SetX(Window.GetWidth() / 2 - 150);
progress_box.sprite.SetY(Window.GetHeight() * 0.75);

progress_bar.original_image = Image("progress_bar.png");
if (progress_bar.original_image.GetWidth() == 0) {
    progress_bar.original_image = Image.Text("", 0.447, 0.635, 0.969, 1, "Sans 1");
}

for (index = 0; index < 100; index++) {
    progress_bar[index].sprite = Sprite();
    progress_bar[index].sprite.SetX(Window.GetWidth() / 2 - 150 + index * 3);
    progress_bar[index].sprite.SetY(Window.GetHeight() * 0.75);
}

fun progress_callback(duration, progress) {
    for (index = 0; index < 100; index++) {
        if (index / 100 < progress) {
            progress_bar[index].sprite.SetImage(progress_bar.original_image.Scale(3, 20));
            progress_bar[index].sprite.SetOpacity(1);
        } else {
            progress_bar[index].sprite.SetOpacity(0);
        }
    }
}

Plymouth.SetBootProgressFunction(progress_callback);
Plymouth.SetRootFileSystemReadWriteFunction(progress_callback);
EOF

# Create simple graphics
echo "Creating simple graphics..."

# Simple logo (hexagon for Arch) - Tokyo Night blue
if command -v convert &> /dev/null; then
    sudo convert -size 64x64 xc:none -fill "#7aa2f7" -stroke "#7aa2f7" -strokewidth 2 \
        -draw "polygon 32,8 56,24 56,40 32,56 8,40 8,24" \
        /usr/share/plymouth/themes/workstation/logo.png
    
    # Progress box - Tokyo Night darker gray
    sudo convert -size 300x20 xc:"#414868" /usr/share/plymouth/themes/workstation/progress_box.png
    
    # Progress bar - Tokyo Night blue
    sudo convert -size 3x20 xc:"#7aa2f7" /usr/share/plymouth/themes/workstation/progress_bar.png
else
    echo "ImageMagick not found, Plymouth will use text fallbacks"
fi

# Set workstation as default Plymouth theme
echo "Setting workstation as default Plymouth theme..."
sudo plymouth-set-default-theme workstation

# Rebuild initramfs to include Plymouth theme
echo "Rebuilding initramfs..."
sudo mkinitcpio -P

echo "Plymouth boot splash configured (omarchy-inspired theme)"