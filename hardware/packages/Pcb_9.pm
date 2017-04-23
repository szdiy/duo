# Copyright (C) 2007 John C. Luciani Jr. 

# This program may be distributed or modified under the terms of
# version 0.2 of the No-Fee Software License published by
# John C. Luciani Jr.

# A copy of the license is at the end of this file.

package        Pcb_9;
require        Exporter;
use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
@ISA         = qw(Exporter);
@EXPORT      = qw(get_field_format scaled_value flag_value_element flags);
@EXPORT_OK   = qw(element_get_field_names dim_field_p element_get_names element_str 
                  ELEMENT_NAME_HIDDEN ELEMENT_SELECTED ELEMENT_SOLDER_SIDE
                  PIN_MASK PIN_ALWAYS_SET PIN_CONNECTED PIN_MOUNTING_HOLE PIN_DISPLAY_NAME
                  PIN_SELECTED PIN_SQUARE PIN_OCTAGONAL PIN_ROUND PIN_SHAPE_MASK 
                  PAD_CONNECTED PAD_DISPLAY_NAME PAD_SELECTED PAD_SOLDER_SIDE PAD_SQUARE
                  PAD_ROUNDED TEXT_ON_SOLDER_SIDE);
%EXPORT_TAGS = (flags => [qw(ELEMENT_NAME_HIDDEN ELEMENT_SELECTED ELEMENT_SOLDER_SIDE
                             PIN_MASK PIN_ALWAYS_SET PIN_CONNECTED PIN_MOUNTING_HOLE PIN_DISPLAY_NAME
                             PIN_SELECTED PIN_SQUARE PIN_OCTAGONAL PIN_ROUND PIN_SHAPE_MASK 
                             PAD_CONNECTED PAD_DISPLAY_NAME PAD_SELECTED PAD_SOLDER_SIDE PAD_SQUARE
                             PAD_ROUNDED TEXT_ON_SOLDER_SIDE)]);

use strict;
use warnings;
use Carp;
use POSIX;
use Data::Dumper;

### \title{Creating PCB Elements with Perl}
### \author{John C. Luciani Jr.}
### \date{\today}
### \maketitle

### \section{Change Log}

### \begin{tabular}{lccp{4in}}
### {\tt Pcb\_9} & ???               & {\tt jcl}   &%
###       1. Fixed a dimension scaling bug in element\_add\_lines.
###          The scaling routine now scales an array of points.
###          This bug was reported by Ben Jackson.\\
###   &&& 2. The scaling routines now accept a dimension suffix which will 
###          override the default dimension.\\
### {\tt Pcb\_8} & 19-Mar-2007       & {\tt jcl}   &%
###       1. Removed the export of element\_add\_arc. Not necessary (OO).\\
###   &&& 2. Corrected the mask and clearance parameters in the pin, pad and pin\_oval procedures.\\
###   &&& 3. Removed the Mark command since the mark data is now in the Element header.\\
###   &&& 4. Exported element\_str and added a scale\_factor parameter (default value of 100)\\
###   &&& 5. the key to specify dimensional units (input\_dim) was changed to dim\\
###   &&& 6. Fixed the dimension scaling problem in {\tt add\_element\_lines}\\
###   &&& 7. Corrected the documentation for {\tt element\_add\_pin\_oval}\\
### {\tt Pcb\_7} & 25 March 2005       & {\tt jcl}   &%
###       1. changed the definition of the mask and clearance.\\
###   &&& 2. Fixed the mask and clearance parameters in the pin, pad and pin\_oval procedures.\\
### {\tt Pcb\_6} & 22 March 2005 & {\tt jcl} &%
###       1. The {\tt element\_add\_rectangle} command now uses the {\tt x} and {\tt y}
###          parameters. The center of the rectangle was always placed at (0,0)\\
###   &&& 2. The {\tt pin\_one\_square} key-value pair was not getting properly tested
###          in the {\tt element\_add\_pin} procedure.\\
###   &&& 3. Added the {\tt clearance} and the {\tt mask} parameters to {\tt element\_add\_pad\_rectangle}.\\
### {\tt Pcb\_5} & 6 March 2005 & {\tt jcl} &%
###       1. Added the {\tt element\_add\_lines} command.\\
###   &&& 2. added the {\tt element\_add\_pin\_oval} command.\\
###   &&& 3. Modified the debug print messages.\\
###   &&& 4. Fixed constant for octagonal pads.\\
###   &&& 5. Fixed errors in the EXPORT\_OK and EXPORT\_TAGS declarations.\\
###   &&& 6. Added {\tt element\_get\_names}.\\
### {\tt Pcb\_4} & 27 February 2005     & {\tt jcl} &% 
###    1. Modified the debug strings to output mm and mils.\\

###    &&& 2. Fixed the {\tt scale\_factor} subroutine. {\tt
###    scale\_factor} did not correctly convert from mils to mm. I did
###    not test (or use) the conversion to mm until I modified the
###    debug strings\\

### {\tt Pcb\_3} & 7 February 2005 & {\tt jcl } & Initial Release\\
### \end{tabular}

### \section{Pcb\_9}

### This document describes a set of Perl routines that can be used to
### create component footprints for the circuit board layout program
### \href{http://bach.ece.jhu.edu/~haceaton/pcb}{PCB}. These routines
### reside in a file called |Pcb_|\<n>|.pm| where \<n> is the current
### revision number of the package. Only the new format of PCB
### elements is output. The differences (that I am aware of) between
### the old and new formats are:

### \begin{itemize}
### \item Dimensions are in hundreths of a mil.
### \item The argument delimiters are square brackets |[]|
### \item The element command adds the |mark_x| and |mark_y| parameters
### \item The pin and pad command add clearance and mask parameters.
### \end{itemize}
###\par

### \subsection*{Requirements}

### These routines should run with a standard Perl distribution. The
### only packages used are |POSIX| and |Carp|.\par

### \subsection*{Usage} 

### These routines are object oriented. A PCB object is created using
### |new| and all subsequent method calls use this
### object. |element_begin| starts a new element. |element_output|
### outputs the element file. |element_add_mark| sets the component
### centroid. |element_set_text_xy| sets the text position for the
### reference designator. The names of the methods used to draw
### elements all start with the string |element_add|. Arguments for
### the method calls are key-value pairs. The keys are parameter
### strings defined in
### \href{http://pcb.sourceforge.net/pcb-20050127.html/index.html}{pcb.html}.\par

### \medskip\noindent To use these routines in a Perl script to create a PCB element:

### \begin{enumerate}
### \item Include the PCB routines |use Pcb_|\<n>|;|
### \item Create a PCB object using |new|
### \item Begin an element using |element_begin|
### \item Add copper to the element using |element_add_pin| or |element_add_pad|
### \item Add silkcreen elements using |element_add_line|, |element_add_arc|,
### \item Mark the centroid using |element_add_mark|. The mark can
###       also be set using parameters of the |element_begin| method.
### \item Add the text location for the reference designator using |element_set_text_xy|
###       The text location can also be set using parameters of the |element_begin| method.
### \item Output the element to a file using |element_output|
### \end{enumerate}

### The simple example in \autoref{lst:res example} creates a
### quarter~watt through-hole resistor.  The example in
### \autoref{lst:smd example} creates a variety of two terminal SMD
### footprints ranging in size from |0402| to |2512|. The example in
### \autoref{lst:th example} creates Molex 8624 series header
### connector footprints. The example in \autoref{lst:tqfn example}
### creates TQFN footprints for a variety of Maxim parts.

### These examples place files in the directory |./tmp|. This can be
### easily changed by changing the |element_begin| call.

###\lstinputlisting[%
###     label=lst:res example,%
###     caption=1/4 Watt Resistor Example]{pcb-example-res}

### \section{Examples}
### \label{sec:examples}

###\lstinputlisting[%
###     label=lst:to220 example,%
###     caption=TO220 Pads]{pcb-example-TO220-pads}

### \newpage
###\lstinputlisting[%
###     label=lst:smd example,%
###     caption=SMD Element Creation Example]{pcb-example-smd}

###\newpage
###\lstinputlisting[%
###     label=lst:th example,%
###     caption=Header Connector Creation Example 1]{pcb-example-hdr1}

###\newpage
###\lstinputlisting[%
###     label=lst:th example,%
###     caption=Header Connector Creation Example 2]{pcb-example-hdr2}

###\newpage
###\lstinputlisting[%
###     label=lst:tqfn example,%
###     caption=TQFN Element Creation Example]{pcb-example-tqfn}

### \section{Element Flags}

### The element flag field determines the state of an element. The bit
### values are:

### @key_value_table@ 
use constant ELEMENT_NAME_HIDDEN => 0x10;  ###    bit 4:  the element name is hidden
use constant ELEMENT_SELECTED    => 0x40;  ###    bit 6:  element has been selected
use constant ELEMENT_SOLDER_SIDE => 0x80;  ###    bit 7:  element is located on the solder side
### @end_key_value_table@ Element Flags 

### \section{Text Flags}

### @begin_key_value_table@ 
use constant TEXT_DIRECTION_0   => 0;  ### Horizontal
use constant TEXT_DIRECTION_90  => 1;  ### 90  degrees counter-clockwise
use constant TEXT_DIRECTION_180 => 2;  ### 180 degrees counter-clockwise
use constant TEXT_DIRECTION_270 => 3;  ### 270 degrees counter-clockwise
### @end_key_value_table@ Text Direction Flags

### @begin_key_value_table@ 
use constant TEXT_SELECTED       => 0x40;  ###   bit 6:  the text has been selected
use constant TEXT_ON_SOLDER_SIDE => 0x80;  ###   bit 7:  the text is on the solder (back) side of the board
use constant TEXT_ON_SILKSCREEN  => 0x400; ###   bit 10: the text is on the silkscreen layer
### @end_key_value_table@ Text Flags

### \section{Pin Flags}

### @key_value_table@ 
use constant PIN_MASK          => 0xFFFD;  ###
use constant PIN_ALWAYS_SET    => 0x0001;  ###    bit 0:  always set
                                           ###    bit 1:  always clear
use constant PIN_CONNECTED     => 0x0004;  ###    bit 2:  set if pin was found during a connection search
use constant PIN_MOUNTING_HOLE => 0x0008;  ###    bit 3:  set if pin is only a mounting hole (no copper annulus)
use constant PIN_DISPLAY_NAME  => 0x0020;  ###    bit 5:  display the pins name
use constant PIN_SELECTED      => 0x0040;  ###    bit 6:  pin has been selected
use constant PIN_SQUARE        => 0x0100;  ###    bit 8:  pin is drawn as a square
use constant PIN_OCTAGONAL     => 0x0800;  ###    bit 12: set if pin is drawn with an octagonal shape
use constant PIN_ROUND         => 0x0000;  ###
use constant PIN_SHAPE_MASK    => 0xEEFF;  ###
### @end_key_value_table@ Pin Flags

### \section{Pad Flags}

### @key_value_table@ 
use constant PAD_CONNECTED    => 0x0004; ###    bit 2:  set if pad was found during a connection search
use constant PAD_DISPLAY_NAME => 0x0020; ###    bit 5:  display the pads name
use constant PAD_SELECTED     => 0x0040; ###    bit 6:  pad has been selected
use constant PAD_SOLDER_SIDE  => 0x0080; ###    bit 7:  pad is located on the solder side
use constant PAD_SQUARE       => 0x0100; ###    
use constant PAD_ROUNDED      => 0x0800; ###    bit 11: pad has rounded corners
### @end_key_value_table@ Pad Flags

### \Method new\\

### \Usage Pcb_9 -> new\\

### \Description

### Creates an object that is used to make PCB element files. Default
### parameters for the various element drawing commands can be
### initialized using a key-value parameter list.

### \medskip\noindent The valid keys and default values are in
### \autoref{tab:kv new}

sub new {
    my $class = shift;
    my $self = { 
                 ### @key_value_table@ 
                 line_thickness => 10,    ### thickness used in drawing silkscreen lines
                 arc_thickness => 10,     ### thickness used in drawing silkscreen arcs
                 thickness => 10,         ### thickness used in drawing any silkscreen line
                 pin_flags => 0,          ### flags used in creating element pins (See \autoref{tab:kv pin flags})
                 pad_flags => PAD_SQUARE, ### flags used in creating pads
                 font_size => 50,         ### size in ??? of the silkscreen found
                 clearance => 10,         ### \clearanceDEF
                 mask      => 10,         ### \maskDEF
                 debug => 0,              ### debug messages. no messages (0). object methods (1). object methods + internal subroutines (2)
                 ### @end_key_value_table@ Keys for Method new | new
                 &_scale_dim(dim => 'mils', @_),
               };
    bless $self, $class; # bless $self into the designated class

    printf("(new) Creating a new Pcb object\n")
        if $self -> debug_p;

    # initialization

    return $self;
}

### \Example

### To create a new object that will display object method debugging
### messages:\par
### \medskip\noindent
### \begin{lstlisting}[numbers=none,frame=none]
### my $Pcb = Pcb_9 -> new(debug => 1);
### \end{lstlisting}




### \Method element_begin\\

### \Usage Pcb -> element_begin\\

### \Description

### Initializes a new Pcb element. If an element was previously
### created but not output a call to |element_begin| will remove it.

### \medskip\noindent The valid keys and default values are in
### \autoref{tab:kv element-begin}

sub element_begin {
    my $self = shift;
    $self->{element} = 
    { 
        ### @key_value_table@ 
        flags => 0,                        ### \elementflagsDEF
        description => '',                 ### \descriptionDEF
        layout_name => '',                 ### \layoutnameDEF
        value => '',                       ### \valueDEF
        mark_x => 0,                       ### \markxDEF
        mark_y => 0,                       ### \markyDEF
        text_x => 0,                       ### \textxDEF
        text_y => 0,                       ### \textyDEF
        direction => 0,                    ### \directionDEF
        scale => 100,                      ### \scaleDEF
        text_flags => 0,                   ### \textflagsDEF
        output_file => 'PCB_ELEMENT.TMP',  ### Element filename
        pin_one_square => 0,               ### Sets a default value that is used when creating a pin.
        dim => 'mils',                     ### units default to mils
        ### @end_key_value_table@ Keys for Method element\_begin | element-begin
        _elements => [],
        $self -> scale_dim(@_)
    };

    printf("(element_begin) Creating element file %s\n", $self -> element_get('output_file'))
        if $self -> debug_p;

}       

### \Example

### To begin a 1/4 Watt resistor element with dimension values in mils:\par
### \medskip\noindent
### \begin{lstlisting}[numbers=none,frame=none]
### $Pcb -> element_begin(description => 'resistor',
###                       output_file => '025W',
###                       dim   => 'mils');
### \end{lstlisting}


### \Method element_output\\

### \Usage Pcb -> element_output\\

### \Description

### |element_output| outputs the element drawing commands to a
### file. At this time there are no parameters that are valid for the
### \<parameter list>.

sub element_output ($) { 
    my ($self) = @_;
    my $ref = $self->{element};
    if (defined $ref->{output_file}) {
        my $output_file = $ref->{output_file};
        open(OUTFILE, ">$output_file") or 
            croak "(Pcb) (element_output) Could not open $output_file for output";
        printf(OUTFILE "Element[0x%x \"%s\" \"%s\" \"%s\" %i %i %i %i %i %i 0x%x]\n",
               hex($ref->{flags}),
               $ref->{description},
               $ref->{layout_name},
               $ref->{value},
               $ref->{mark_x} * 100,
               $ref->{mark_y} * 100,
               $ref->{text_x} * 100,
               $ref->{text_y} * 100,
               $ref->{direction},
               $ref->{scale},
               hex($ref->{text_flags}));
        printf(OUTFILE "(\n");
        foreach (@ { $ref->{_elements} }) {
            printf(OUTFILE "   %s\n", &element_str(@$_));
        }
        printf(OUTFILE ")\n");
        close(OUTFILE) or croak "(Pcb) (element_output) Could not close $output_file";
    } else {
        carp "(Pcb) (element_output) Element filename was not defined";
    }
}

### \Method element_add_line\\

### \Usage Pcb -> element_add_line\\

### \Description

### Creates a silkscreen line of a specified thickness (|thickness|)
### between two \points.

### \BeginKVTable
###  x1 & & \xoneDEF \\
###  y1 & & \yoneDEF \\
###  x2 & & \xtwoDEF \\
###  y2 & & \ytwoDEF \\
###  thickness & & \thicknessDEF \\
### \EndKVTable{Keys for Method element\_add\_line}{element-add-line}

sub element_add_line ($%) { 
    my $self = shift;
    my %v = (thickness => $self -> element_get('line_thickness'),
             $self -> scale_dim(@_));
    printf("   (element_add_line) adding line from %s to %s with thickness %s\n",
           &_debug_str_point($v{x1}, $v{y1}),
           &_debug_str_point($v{x2}, $v{y2}),
           &_debug_str_dim($v{thickness}))
        if $self -> debug_p;
    $self -> _element_add('ElementLine', %v);
}

### \Example

### To create a 200mil long silkscreen line that is centered at |(0,0)| that is
### 10 mils thick\par
### \medskip\noindent
### \begin{lstlisting}[numbers=none,frame=none]
### $Pcb -> element_add_line(x1 => -100, y1 => 0, 
###                          x2 =>  100, y2 => 0,
###                          thickness => 10);
### \end{lstlisting}


### \Method element_add_arc\\

### \Usage Pcb -> element_add_arc\\

### \Description

### Creates a silkscreen arc with a specified |width| and |length|
### centered at a \point. 

### \BeginKVTable
### x & & \xDEF\\
### y & & \yDEF\\
### width & & horizontal width of the arc\\
### height & & vertical length of the arc\\
### start\_angle & & Starting angle of the arc (degrees) \\
### delta\_angle & & Angle swept by the arc (degrees)\\
### thickness & & line thickness\\
### \EndKVTable{Keys for Method element\_add\_arc}{element-add-arc}


sub element_add_arc ($%) { 
    my $self = shift;
    my %v = (thickness => $self -> get('arc_thickness'),
             $self -> scale_dim(@_));
    printf("   (element_add_arc) center at %s, start angle=%.0f, delta angle=%.0f\n",
           &_debug_str_point($v{x}, $v{y}),
           map { $v{$_} } qw(start_angle delta_angle)) 
        if $self -> debug_p;
    $self -> _element_add('ElementArc', %v);
}

### \Example

### To create a silkscreen circular arc centered at |(0,0)| with a
### line thickness of 10 mils, radius of 200 mils that starts at
### 45$\Deg$ and sweeps for 135$\Deg$:\par

### \medskip\noindent
### \begin{lstlisting}[numbers=none,frame=none]
### $Pcb -> element_add_arc(start_angle => 45, 
###                         delta_angle => 135,
###                         x => 0,
###                         y => 0,
###                         width => 200,
###                         height => 200,
###                         thickness => 10);
### \end{lstlisting}

### For an ellipse set the width and height to unequal values.


### \Method element_add_pin\\

### \Usage Pcb -> element_add_pin\\

### \Description

### Adds a pin to an element

### \BeginKVTable
### x & & \xDEF\\
### y & & \yDEF\\
### thickness & & width of the copper pad\\
### clearance & & \clearanceDEF\\
### mask      & & \maskDEF\\
### drill\_hole & & diameter of the hole that is drilled at the center of the pad\\
### name        & & string\\
### pin\_number  & & \pinnumberDEF\\
### flags       & & See \autoref{tab:kv pin flags}\\
### \EndKVTable{Keys for Method element\_add\_pin}{element-add-pin}

sub element_add_pin {
    my $self = shift;
    my %v = ( clearance => $self -> get('clearance'),
              mask      => $self -> get('mask'),
              name      => '',
              flags     => $self -> get('pin_flags'),
              $self -> scale_dim(@_));

    if ($v{pin_number} == 1 && $self -> element_get('pin_one_square')) {
        $v{flags} &= PIN_SHAPE_MASK;
        $v{flags} |= PIN_SQUARE;
    }
    $v{flags} &= PIN_MASK;
    $v{flags} |= PIN_ALWAYS_SET;

    # The mask parameter that was passed as an argument is the
    # clearance between the edge of the copper and the edge of the
    # masking material. The mask value that PCB wants is the total
    # diameter of hole in the mask.

    $v{mask} = $v{mask} * 2 + $v{thickness};
    $v{clearance} *= 2;

    printf("   (element_add_pin) center at %s, diameter=%s, pin_number=%s, flags=0x%x\n",
           &_debug_str_point($v{x}, $v{y}),
           &_debug_str_dim($v{thickness}),
           defined $v{pin_number} ? sprintf("%i", $v{pin_number}) : '?',
           $v{flags})
        if $self -> debug_p;

    $self -> _element_add('Pin', %v);
}

### \Example
### 
### To place a pin with a round pad at |(-100,0)| with a pad diameter of 55 mils, a drill hole diameter
### of 35 mils, soldermask clearance of 10 mils, a copper clearance of 9 mils, and a pin number of one:\par
### \medskip\noindent
### \begin{lstlisting}[numbers=none,frame=none]
### $Pcb -> element_add_pin(x => -100, y => 0,
###                         thickness  => 55,
###                         drill_hole => 35,
###                         mask => 10,
###                         clearance => 9,
###                         pin_number => 1);
### \end{lstlisting}

### \Method element_add_pad\\

### \Usage Pcb -> element_add_pad\\

### \Description

### Pads are created by drawing a line, with a specified thickness,
### between two points.  The line is drawn with a square nib and
### extends beyond each end point by a distance of ${\tt
### thickess}\over 2$.

### \BeginKVTable
###  x1 & & \xoneDEF \\
###  y1 & & \yoneDEF \\
###  x2 & & \xtwoDEF \\
###  y2 & & \ytwoDEF \\
###  thickness & & \thicknessDEF \\
###  clearance & & \clearanceDEF\\
###  mask      & & \maskDEF\\
###  name      & & \padnameDEF\\
###  pad\_number & & \padnumberDEF\\
###  flags       & & See \autoref{tab:kv pad flags}\\
### \EndKVTable{Keys for Method element\_add\_line}{element-add-line}

sub element_add_pad {
    my $self = shift;
    my %v = (flags     => $self -> get('pad_flags'),
             clearance => $self -> get('clearance'),
             mask      => $self -> get('mask'),
             $self -> scale_dim(@_));
    printf("   (element_add_pad) from %s to %s with thickness %s\n",
           &_debug_str_point($v{x1}, $v{y1}),
           &_debug_str_point($v{x2}, $v{y2}),
           &_debug_str_dim($v{thickness}))
        if $self -> debug_p;

    $v{mask} = $v{mask} * 2 + $v{thickness};
    $v{clearance} *= 2;

    $self -> _element_add('Pad', %v);
    
}

### \Example

### To create a pad that is centered at |(0,0)| that is 100 mils long and 50 mils thick\par
### has a soldermask clearance of 10 mils, a copper clearance of 9 mils and is numbered one:\par
### \medskip\noindent
### \begin{lstlisting}[numbers=none,frame=none]
### $Pcb -> element_add_pad(x1 => -25, y1 => 0, 
###                         x2 => 25,  y2 => 0,
###                         thickness  => 50,
###                         mask       => 10,
###                         clearance  => 9,
###                         pad_number => 1);
### \end{lstlisting}




### \Method element_add_pad_rectangle\\

### \Usage Pcb -> element_add_pad_rectangle\\

### \Description

### Create a pad with a specified width and length that is centered at
### a point |(x,y)|. The length is in x-direction and the width is in
### the y-direction.

### \BeginKVTable
### x           &  & \xDEF\\
### y           &  & \yDEF\\
### width       &  & \widthDEF\\
### length      &  & \lengthDEF\\
### clearance   &  & \clearanceDEF\\
### mask        &  & \maskDEF\\
### name        &  & \padnameDEF\\
### pin\_number &  & \pinnumberDEF\\
### \EndKVTable{Keys for Method element\_add\_pad\_rectangle}{element-add-pad-rectangle}


sub _print_missing_fields  { 
    my ($sub_name, $ref, @fields) = @_;
    my $missing_fields = 0;
    foreach (@fields) {
	next if defined $ref->{$_};
	printf("(%s) field %s is undefined\n", $sub_name, $_);
	$missing_fields = 1;
    }
    return($missing_fields);
}


sub element_add_pad_rectangle { 
    my $self = shift;
    my %v = (flags => $self -> get('pad_flags'),
             clearance => $self -> get('clearance'),
             mask      => $self -> get('mask'),
             $self -> scale_dim(@_));

    die if &_print_missing_fields('element_add_pad_rectangle', 
				  \%v, 
				  qw(width length x y name pin_number clearance mask));

    my ($x1, $x2, $y1, $y2);
    my $thickness;
    if ($v{width} < $v{length}) {
        $thickness = $v{width};
        $y1 = $v{y}; $y2 = $v{y};
        $x1 = $v{x} - ($v{length} - $thickness) / 2;
        $x2 = $v{x} + ($v{length} - $thickness) / 2;
    } else {
        $thickness = $v{length};
        $x1 = $v{x}; $x2 = $v{x};
        $y1 = $v{y} - ($v{width} - $thickness) / 2;
        $y2 = $v{y} + ($v{width} - $thickness) / 2;
    }

    printf("   (element_add_pad_rectangle) width = %s, length = %s, center at %s\n",
           &_debug_str_dim($v{width}),
           &_debug_str_dim($v{length}),
           &_debug_str_point($v{x}, $v{y}))
        if $self -> debug_p;

    $self -> element_add_pad(x1 => $x1, x2 => $x2,
                             y1 => $y1, y2 => $y2,
                             thickness => $thickness,
                             name => $v{name},
                             pin_number => $v{pin_number},
                             clearance => $v{clearance},
                             mask => $v{mask},
			     flags => $v{flags},
                             dim => 'mils');
}



### \Method element_add_pin_oval\\

### \Usage Pcb -> element_add_pin_oval\\

### \Description

### Create a pad with a specified width and length that is centered at
### a point |(x,y)|. The length is in x-direction and the width is in
### the y-direction. The corners of the pad are rounded.\par

### \medskip\noindent This is actually a hybrid object consisting of a
### component side pad, a solder side pad and a pin placed at the same
### center point.

### \BeginKVTable
### x           &  & \xDEF\\
### y           &  & \yDEF\\
### width       &  & \widthDEF\\
### length      &  & \lengthDEF\\
### drill\_hole &  & diameter of the hole that is drilled at the center of the pad\\
### name        &  & \padnameDEF\\
### pin\_number &  & \pinnumberDEF\\
### \EndKVTable{Keys for Method element\_add\_pin\_oval}{element-add-pin-oval}

sub element_add_pin_oval { 
    my $self = shift;
    my %v = ( clearance => $self -> get('clearance'),
              mask      => $self -> get('mask'),
              $self -> scale_dim(@_));
    my ($x1, $x2, $y1, $y2);
    my $thickness;
    if ($v{width} < $v{length}) {
        $thickness = $v{width};
        $y1 = $v{y}; $y2 = $v{y};
        $x1 = $v{x} - ($v{length} - $thickness) / 2;
        $x2 = $v{x} + ($v{length} - $thickness) / 2;
    } else {
        $thickness = $v{length};
        $x1 = $v{x}; $x2 = $v{x};
        $y1 = $v{y} - ($v{width} - $thickness) / 2;
        $y2 = $v{y} + ($v{width} - $thickness) / 2;
    }

    printf("   (element_add_pad_oval) width = %s, length = %s, center at %s\n",
           &_debug_str_dim($v{width}),
           &_debug_str_dim($v{length}),
           &_debug_str_point($v{x}, $v{y}))
        if $self -> debug_p;


    $self -> element_add_pad(x1 => $x1, x2 => $x2,
                             y1 => $y1, y2 => $y2,
                             thickness => $thickness,
                             flags => PAD_ROUNDED,
                             dim => 'mils',
                             map { $_ => $v{$_} } qw(name pin_number clearance mask));

    $self -> element_add_pad(x1 => $x1, x2 => $x2,
                             y1 => $y1, y2 => $y2,
                             thickness => $thickness,
                             flags => PAD_ROUNDED | PAD_SOLDER_SIDE,
                             dim => 'mils',
                             map { $_ => $v{$_} } qw(name pin_number clearance mask));


    $self -> element_add_pin(x => ($x1 + $x2) / 2,
                             y => ($y1 + $y2) / 2,
                             name => '', 
                             pin_number => $v{pin_number},
                             thickness => $thickness,
                             dim => 'mils',
                             drill_hole => $v{drill_hole},
                             mask => $v{mask},
                             flags => 0,
                             clearance => $v{clearance});
}

### \Example

### To place a pin with an oval pad at |(-100,0)| with a pad diameter
### of 55 mils, a drill hole diameter of 35 mils, soldermask clearance
### of 10 mils, a copper clearance of 9 mils, and a pin number of
### one:\par

### \medskip\noindent
### \begin{lstlisting}[numbers=none,frame=none]
### $Pcb -> element_add_pin_oval(x => -100, y => 0,
###                              thickness  => 55,
###                              drill_hole => 35,
###                              mask       => 10,
###                              clearance  => 9,
###                              pin_number => 1);
### \end{lstlisting}


### \Method element_add_mark\\

### \Usage Pcb -> element_add_mark\\

### \Description

### The mark is a positioning hint. |element_add_mark| places the mark at 
### at a \point.

### \BeginKVTable
###  x & & \xDEF \\
###  y & & \yDEF \\
### \EndKVTable{Keys for Method element\_add\_mark}{element-add-mark}

sub element_add_mark ($%) { 
    my $self = shift;
    my %v = $self -> scale_dim(@_);
    printf("   (element_add_mark) mark at %s\n", 
           &_debug_str_point($v{x}, $v{y}))
        if $self -> debug_p;
    $self -> _element_add('Mark', %v);
}

### \Method element_add_lines\\

### \Usage Pcb -> element_add_lines\\

### \Description

### Draws silkscreen lines using the specified line end points. Lines
### are drawn from point to point until all the points are connected.

### \BeginKVTable
### points      &  & reference to a list containing x,y coordinates for line end points.\\
### thickness   &  & \thicknessDEF\\
### \EndKVTable{Keys for Method element\_add\_lines}{element-add-lines}

sub element_add_lines { 
    my $self = shift;
    my %v = (thickness => $self -> element_get('line_thickness'),
             $self -> scale_dim(@_));
    my @pts = @ { $v{points} };
    while (@pts) {
        my ($x1, $y1) = splice @pts, 0, 2;
        last if $#pts < 1;
        $self -> element_add_line(x1 => $x1, y1 => $y1, 
				  x2 => $pts[0], y2 => $pts[1],
                                  thickness => $v{thickness},
                                  dim => 'mils');
    }
}


### \Method element_add_rectangle\\

### \Usage Pcb -> element_add_rectangle\\

### \Description

### Draws a silkscreen rectangle with a specified |width| and |length| at a \point.

### \BeginKVTable
### x           &  & \xDEF\\
### y           &  & \yDEF\\
### width       &  & rectangle width  (y direction)\\
### length      &  & rectangle length (x direction)\\
### thickness   &  & \thicknessDEF\\
### \EndKVTable{Keys for Method element\_add\_rectangle}{element-add-rectangle}

sub element_add_rectangle { 
    my $self = shift;
    my %v = (x => 0,
             y => 0,
             thickness => $self -> element_get('line_thickness'),
             $self -> scale_dim(@_));

    # x1,y1 lower left
    # x2,y2 upper right

    my $x1 = $v{x} - $v{length} / 2; 
    my $x2 = $v{x} + $v{length} / 2;
    my $y1 = $v{y} + $v{width} / 2;
    my $y2 = $v{y} - $v{width} / 2;
    $self -> element_add_lines(points => [$x1, $y1, $x1, $y2, $x2, $y2, $x2, $y1, $x1, $y1],
                               %v,
                               dim => 'mils');
}


### \Method element_set_text_xy\\

### \Usage Pcb -> element_set_text_xy\\

### \Description

### Sets the position of the reference designator text. 

### \BeginKVTable
###  x & & \xDEF \\
###  y & & \yDEF \\
###  font\_size & & \\
### \EndKVTable{Keys for Method element\_add\_mark}{element-add-mark}

sub element_set_text_xy ($%) { 
    my $self = shift;
    my %v = (font_size => $self -> element_get('font_size'),
             $self -> scale_dim(@_));
    printf("   (element_set_text_xy) text at %s\n", 
           &_debug_str_point($v{x}, $v{y} - $v{font_size}))
        if $self -> debug_p;
    $self -> element_set(text_x => $v{x},
                         text_y => $v{y} - $v{font_size});
}

### \Method element_set\\

### \Usage Pcb -> element_set\\

### \Description

### Sets values in the element hash table. This should be the only
### method used to set values in the element hash. \<parameter list>
### contains key-value pairs.

sub element_set ($@) { 
    my ($self, @key_value_pairs) = @_;
    while (@key_value_pairs) {
        my ($k, $v) = splice @key_value_pairs, 0, 2;
        next if $k =~ /^_/; # do not set private variables
        $self->{element}{$k} = $v;
    }
}

### \Method element_get\\

### \Usage Pcb -> element_get\\

### \Description

### Returns a value, from the element hash, for each key specified in
### \<parameter list>. If the value is undefined in the element hash
### then a value from the Pcb object hash is returned. A value of
### |undef| is returned if neither hash contains a defined value for
### the key.\par

### \medskip\noindent This should be the only method used to retrieve
### values from the element hash. \<parameter list> contains a list of
### keys.\par

### \medskip\noindent 

sub element_get ($@) { 
    my ($self, @keys) = @_;
    my @retvals;
    foreach my $key (@keys) {
        my $value = $self->{element}{$key};
        $value = $self -> get($key) unless defined $value;
        push @retvals, $value;
    }
    return @retvals    if wantarray();
    return $retvals[0] if defined wantarray();
    return;
}


### \Method get\\

### \Usage Pcb -> get\\

### \Description

### Retrieves values from the PCB object hash.  This should be the
### only method used to retrieve values from the PCB object hash.
### \<parameter list> contains a list of keys.

sub get ($@) { 
    my ($self, @keys) = @_;
    my @retvals = map { $self->{$_} } @keys;
    return @retvals    if wantarray();
    return $retvals[0] if defined wantarray();
    return;
}

sub debug_p { shift() -> get('debug') }


# Since these debug routines are only meant to be called from within
# the Pcb package distance is assumed to be mils.

sub _debug_str_dim ($) { 
    my $dim = shift;
    return 'undef' unless defined $dim;
    sprintf("%.2f (%.2f)", $dim, &scaled_value($dim, 'mils', 'mm'));
}

sub _debug_str_point ($$$) { 
    my ($x, $y) = @_;
    return sprintf("x=%s, y=%s", (map { &_debug_str_dim($_) } $x, $y));
}


### \Method element_dump\\

### \Usage Pcb -> element_dump\\

### \Description

### A debugging procedure that Prints out the element command drawing
### commands to STDOUT. 

sub element_dump { 
    my ($self) = @_;
    my $ref = $self->{element};
    my @fields = qw(flags description layout_name value text_x text_y direction scale text_flags);
    foreach (@fields) {
        printf("field %s = %s\n", $_, $ref->{$_});
    }
    printf("Element(0x%x \"%s\" \"%s\" \"%s\" %i %i %i %i 0x%x)\n", map {$ref->{$_}} @fields);
    printf("(\n");
    foreach (@ { $ref->{_elements} }) {
        printf("   %s\n", &element_str(@$_));
    }
    printf(")\n");
}



my %Element_fields;
my %Fields;

BEGIN 
{

    %Element_fields = ( Element     => [qw(flags description layout_name value mark_x mark_y
                                           text_x text_y direction scale text_flags)],
                        ElementLine => [qw(x1 y1 x2 y2 thickness)],
                        ElementArc  => [qw(x y width height start_angle delta_angle thickness)],
                        Pin         => [qw(x y thickness clearance mask drill_hole name pin_number flags)],
                        Pad         => [qw(x1 y1 x2 y2 thickness clearance mask name pin_number flags)]);

    %Fields = ((map { $_ => { dim => 0, format => '0x0%x'} }
                    qw(flags text_flags)),
               (map { $_ => { dim => 1, format => '%i'} } 
                    qw(text_x text_y
                       mark_x mark_y
                       clearance mask
                       line_thickness arc_thickness
                       x1 y1 x2 y2 
                       thickness width 
                       height length x y drill_hole
                       xoffset yoffset
		       points
                       )),
                (map { $_ => { dim => 0, format => '%i' }  } 
                     qw(start_angle delta_angle direction scale)),
                (map { $_ => { dim => 0, format => '"%s"' } }
                     qw(description layout_name value name pin_number)));

}

sub dim_field_p ($) { 
    my $field_name = shift;
    return $Fields{$field_name}{dim} if exists $Fields{$field_name}{dim};
    return 0;
}

sub element_p     { defined $Element_fields{ shift() } }

sub get_field_format {
    my $name = shift;
    join(' ', 
         map { defined $Fields{$_}{format} ? $Fields{$_}{format} : "***$_***" } 
         &element_get_field_names($name));
}

sub element_get_names  { 
    return keys %Element_fields;
}

sub element_get_field_names ($) { 
    my ($name) = @_;
    return () unless defined $Element_fields{$name};
    return @ { $Element_fields{$name} };
}

sub element_str { 
    my $element_name = shift;
    my %v = (scale_factor => 100,
	     @_);
    my $str;
    croak "(Pcb) (element_str) Unknown element type '$element_name'", return('') 
        unless &element_p($element_name);
    my @arg;

    foreach my $fn (&element_get_field_names($element_name)) {
        croak "(Pcb) (element_str) Missing field value for field $fn, element $element_name"
            unless defined $v{$fn};

        $v{$fn} *= $v{scale_factor} if &dim_field_p($fn);

        push @arg, $v{$fn};
    }
    $str = sprintf("%s[" . &get_field_format($element_name) . "]", $element_name, @arg);
    return $str;
}

# Scales dimension field values to mils. Field values that are not
# dimensions are left unchanged.  Field names and values are returned
# as a list of key-value pairs.

sub _scale_dim { 
    my %args = (dim => 'mils', @_);
    my @retval;
    foreach my $key (keys %args) {
	push @retval, $key;
        push(@retval, $args{$key}), next unless &dim_field_p($key);
	if (ref($args{$key}) eq '') {
	    push(@retval, &scaled_value($args{$key}, $args{dim}, 'mils'));
	} elsif (ref($args{$key}) eq 'ARRAY') {
	    push(@retval, [ map { &scaled_value($_, $args{dim}, 'mils') } @ { $args{$key} } ]);
	} else {
	    printf("(Pcb_9) (_scale_dim) incorrect reference type %s for arg %s\n", 
		   ref($args{$key}), 
		   $key);
	    croak;
	}
    }
    return (@retval);
}

sub scale_dim ($@) { 
    my ($self, @args) = @_;
    &_scale_dim(dim => $self -> element_get('dim'),
                @args);
}

sub _scale_factor ($) { 
    my ($dim) = @_;
    return undef unless defined $dim;
    return 1    if $dim =~ /^\s*mils?\s*$/;
    return 0.01 if $dim =~ /^\s*mils?100\s*$/;
    return 1000/25.4 if $dim =~ /^\s*mms?\s*$/;
    return undef;
}

sub scaled_value ($$$) { 
    my $value = shift;
    my $from_units = shift || 'mils';
    my $to_units   = shift || 'mils';

    $from_units = $1 if $value =~ s/(\D+)$//;

    return undef unless defined $value;
    return undef unless $value =~ /^[-+.0-9eE]+$/;
    return $value * &_scale_factor($from_units) / &_scale_factor($to_units);
}

# adds element definitions

sub _element_add { 
    my $self = shift;
    push @{ $self->{element}{_elements}}, [@_];
    return unless $self -> debug_p() > 1;
    printf("      (_element_add) %s\n", shift);
    while (@_) {
        my ($k, $v) = splice @_, 0, 2;
        printf("      %s = %s\n", map { defined $_ ? $_ : 'undef' } $k, $v);
    }
}

###\clearpage
###\ifpdfscreen%
###\phantomsection%
###\addcontentsline{toc}{section}{References}%
###\fi%
###\nocite{footprint}
###\nocite{Pcb}
#\bibliographystyle{apacite}
###\bibliography{/local/lan/texmf/bibdb/bibdb}
###\newpage

1;

# Style (adapted from the Perl Cookbook, First Edition, Recipe 12.4)

# 1. Names of functions and local variables are all lowercase.
# 2. The module's persistent variables (either file lexicals
#    or package globals) are capitalized.
# 3. Identifiers with multiple words have each of these
#    separated by an underscore for readability.
# 4. Constants are all uppercase.
# 5. If the arrow operator (->) is followed by either a
#    method name or a variable containing a method name then
#    there is a space before and after the operator.
# 6. Function names, variable names, hash keys that are meant
#    to be used only within the current package have an
#    underscore prefix.


__END__
[test program]
#!/usr/bin/perl

# this is a test program for the various subroutines in the Pcb
# library. It is only meant to test individual routines not create a
# usable component. See the www.luciani.org for the working examples.

use strict;
use warnings;

use Pcb_9;

my $Pcb = Pcb_9 -> new;

$Pcb -> element_begin(description => 'SMD CAP 100 x 200mils');

$Pcb -> element_add_rectangle(width => 100,
                              length => 200);

$Pcb -> element_dump;
$Pcb -> element_output;


$Pcb -> element_begin(description => 'SMD CAP 1mm x 2mils');

$Pcb -> element_add_rectangle(width => '1mm',
                              length => 2);

$Pcb -> element_dump;
$Pcb -> element_output;


##### No-Fee Software License Version 0.2

#### Intent

### The intent of this license is to allow for distribution of this
### software without fee. Usage of this software other than
### distribution, is unrestricted.

#### License

### Permission is granted to make and distribute verbatim copies of
### this software provided that (1) no fee is charged and (2) the
### copyright notice and license statement are preserved on all copies.

### Permission is granted to make and distribute modified versions of
### this software provided that the entire resulting derived work is
### distributed (1) without fee and (2) with a license identical to
### this one.

### This software is provided by the author "AS IS" and any express or
### implied warranties, including, but not limited to, the implied
### warranties of merchantability and fitness for a particular purpose
### are disclaimed. In no event shall the author be liable for any
### direct, indirect, incidental, special, exemplary, or consequential
### damages (including, but not limited to, procurement of substitute
### goods or services; loss of use, data, or profits; or business
### interruption) however caused and on any theory of liability,
### whether in contract, strict liability, or tort (including
### negligence or otherwise) arising in any way out of the use of this
### software, even if advised of the possibility of such damage.

