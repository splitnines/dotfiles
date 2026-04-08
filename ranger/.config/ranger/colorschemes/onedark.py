from ranger.colorschemes.default import Default
from ranger.gui.color import bold

BLACK = default
WHITE = 188
GRAY = 242
BLUE = 75
GREEN = 114
RED = 203
YELLOW = 180
CYAN = 73


class Scheme(Default):
    progress_bar_color = BLUE

    def use(self, context):
        fg, bg, attr = super().use(context)

        bg = BLACK

        if context.selected:
            fg = WHITE
            bg = BLACK
            attr |= bold

        elif context.directory:
            fg = BLUE
            bg = BLACK
            attr |= bold

        elif context.executable and not context.directory:
            fg = GREEN
            bg = BLACK

        elif context.link:
            fg = CYAN
            bg = BLACK

        elif context.socket:
            fg = RED
            bg = BLACK

        elif context.fifo or context.device:
            fg = YELLOW
            bg = BLACK

        elif context.inactive_pane:
            fg = GRAY
            bg = BLACK

        return fg, bg, attr
