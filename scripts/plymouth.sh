#!/bin/bash
# Plymouth boot splash theme setup
set -euo pipefail

echo "Setting up Plymouth boot splash..."

# Create theme directory
echo "Creating Plymouth theme directory..."
sudo mkdir -p /usr/share/plymouth/themes/tokyo-night

# Create Plymouth theme configuration
echo "Creating Plymouth theme configuration..."
sudo tee /usr/share/plymouth/themes/tokyo-night/tokyo-night.plymouth > /dev/null <<'EOF'
[Plymouth Theme]
Name=Tokyo Night
Description=Tokyo Night themed boot splash
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/tokyo-night
ScriptFile=/usr/share/plymouth/themes/tokyo-night/tokyo-night.script
ConsoleLogBackgroundColor=0x1a1b26
MonospaceFont=JetBrainsMono Nerd Font 11
Font=SF Pro Display 11
EOF

# Create Plymouth script file
echo "Creating Plymouth script file..."
sudo tee /usr/share/plymouth/themes/tokyo-night/tokyo-night.script > /dev/null <<'EOF'
# Tokyo Night Plymouth Theme Script

# Set background color
Window.SetBackgroundTopColor(0.102, 0.107, 0.149);     # #1a1b26
Window.SetBackgroundBottomColor(0.102, 0.107, 0.149);  # #1a1b26

# Create and position logo if available
logo.image = Image("logo.png");
if (logo.image) {
    logo.sprite = Sprite(logo.image);
    logo.sprite.SetPosition(Window.GetWidth() / 2 - logo.image.GetWidth() / 2, 
                          Window.GetHeight() / 2 - logo.image.GetHeight() / 2 - 100);
}

# Progress bar setup
progress_box.image = Image("progress_box.png");
progress_bar.image = Image("progress_bar.png");

if (progress_box.image && progress_bar.image) {
    progress_box.sprite = Sprite(progress_box.image);
    progress_bar.sprite = Sprite(progress_bar.image);
    
    progress_box.sprite.SetPosition(Window.GetWidth() / 2 - progress_box.image.GetWidth() / 2,
                                   Window.GetHeight() / 2 + 50);
    progress_bar.sprite.SetPosition(Window.GetWidth() / 2 - progress_bar.image.GetWidth() / 2,
                                   Window.GetHeight() / 2 + 50);
}

# Progress callback
fun progress_callback (duration, progress) {
    if (progress_bar.sprite && progress_box.sprite) {
        progress_bar.sprite.SetImage(progress_bar.image.Scale(progress_bar.image.GetWidth() * progress, 
                                                             progress_bar.image.GetHeight()));
    }
}
Plymouth.SetBootProgressFunction(progress_callback);

# Message display
message_sprite = Sprite();
message_sprite.SetPosition(Window.GetWidth() / 2, Window.GetHeight() / 2 + 120, 0.5, 1);

fun display_normal_callback () {
    message_sprite.SetImage(Image.Text("", 0.478, 0.792, 0.956));  # Tokyo Night blue
}

fun display_password_callback (prompt, bullets) {
    message = Image.Text(prompt, 0.478, 0.792, 0.956);
    bullet_image = Image.Text("•", 0.478, 0.792, 0.956);
    
    message_sprite.SetImage(message);
    
    for (i = 0; i < bullets; i++) {
        bullet_sprite = Sprite(bullet_image);
        bullet_sprite.SetPosition(Window.GetWidth() / 2 + i * 20, Window.GetHeight() / 2 + 150);
    }
}

Plymouth.SetDisplayNormalFunction(display_normal_callback);
Plymouth.SetDisplayPasswordFunction(display_password_callback);
EOF

# Create simple placeholder graphics if ImageMagick is available
if command -v convert &> /dev/null; then
    echo "Creating placeholder graphics..."
    if [ ! -f /usr/share/plymouth/themes/tokyo-night/logo.png ]; then
        # Logo (Arch Linux blue circle)
        sudo convert -size 64x64 xc:none -fill "#7aa2f7" -draw "circle 32,32 32,16" /usr/share/plymouth/themes/tokyo-night/logo.png
        
        # Progress box (dark rounded rectangle)
        sudo convert -size 300x20 xc:"#414868" -fill "#414868" /usr/share/plymouth/themes/tokyo-night/progress_box.png
        
        # Progress bar (Tokyo Night blue)
        sudo convert -size 300x20 xc:"#7aa2f7" -fill "#7aa2f7" /usr/share/plymouth/themes/tokyo-night/progress_bar.png
        
        echo "Placeholder graphics created"
    else
        echo "Graphics already exist"
    fi
else
    echo "ImageMagick not found, skipping placeholder graphics"
fi

# Set Tokyo Night as default Plymouth theme
echo "Setting Tokyo Night as default Plymouth theme..."
sudo plymouth-set-default-theme tokyo-night

# Enable Plymouth in systemd
echo "Enabling Plymouth service..."
sudo systemctl enable plymouth-start 2>/dev/null || true

echo "Plymouth boot splash configured"