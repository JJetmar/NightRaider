const sf = require('sync-folders');
sf(
    ['./NightRaider'],
    'C:\\Program Files (x86)\\World of Warcraft\\_classic_\\Interface\\AddOns',
    {
        watch: true,
        verbose: true,
        quiet: false,
        //type: "copy"
    }
);