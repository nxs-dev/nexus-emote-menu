fx_version('bodacious')
game('gta5')

ui_page "build/index.html"
ui_page_preload "yes"
lua54 "yes"

client_scripts {
    "client.lua",
    "animations.lua"
}

files {
    "build/index.html",
    "build/fonts/**/*.ttf",
    "build/*.*"
}
