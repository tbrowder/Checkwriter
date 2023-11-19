unit class TCheck;
# WARNING - AUTO-GENERATED - EDITS WILL BE LOST

has $.id;
has $.type;
has $.label;
has $.descrip;
has $.x1;
has $.y1;
has $.x2;
has $.y2;

method new($id, $type, $label, $descrip, $x1, $y1, $x2, $y2) {
    self.bless(:$id, :$type, :$label, :$descrip, :$x1, :$y1, :$x2, :$y2);
}

