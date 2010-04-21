// STK Flute
// patch
Flute flute1=> PoleZero f1 => JCRev r1 => dac;
.25 => r1.gain;
.15 => r1.mix;
.99 => f1.blockZero;

flute1.clear( 1.0 );
0.000005 => flute1.jetDelay;
0.400000 => flute1.jetReflection;
0.000000 => flute1.endReflection;
0.000000 => flute1.noiseGain;
0.300000 => flute1.vibratoFreq;
0.100000 => flute1.vibratoGain;
0.800000 => flute1.pressure;


Flute flute2 => PoleZero f2 => JCRev r2 => dac;
.25 => r2.gain;
.15 => r2.mix;
.99 => f2.blockZero;

flute2.clear( 1.0 );
0.001108 => flute2.jetDelay;
0.500000 => flute2.jetReflection;
0.000000 => flute2.endReflection;
0.000000 => flute2.noiseGain;
0.500000 => flute2.vibratoFreq;
0.100000 => flute2.vibratoGain;
0.800000 => flute2.pressure;

// our notes
[ 57, 59, 60, 62, 64, 65, 67, 69 ] @=> int notes1[];
[ 57, 59, 60, 62, 64, 65, 67, 69 ] @=> int notes2[];

// infinite time-loop
while( true )
{
    // print
    <<< "---", "" >>>;

    for(notes1.cap() - 1 => int i; i >= 0; i-- )
    {
        play( 12 + extract(i, notes1), 12+extract(i, notes2), 0.75 );
        400::ms => now;
    }
}

fun void print_array(int array[])
{
	<<< "[" >>>;
	for(int i; i<array.cap(); i++) {
		<<< array[i],", " >>>;
	}
	<<< "]" >>>;
}

fun int extract(int index, int array[])
{
	//Select
	 Std.rand2(0, index) => int result;
	 
	 //Swap
	 //<<< "---","" >>>;
	 //<<< array[result], array[index]>>>;
	 array[result] => int temp;
	 array[index] => array[result];
	 temp => array[index];
	 //<<< array[result], array[index]>>>;
	 <<< temp, "">>>;
	 
	 return temp;
}

// basic play function (add more arguments as needed)
fun void play( float note1, float note2, float velocity )
{
    // start the note
	
	Std.mtof( note1 ) => flute1.freq; 
    Std.mtof( note2 ) => flute2.freq;
    velocity => flute1.noteOn;
    velocity => flute2.noteOn;
	
	
	Std.rand2f(.25, 0.50) => float flute_gain;
	flute_gain => r1.gain;
	0.75 - flute_gain => r2.gain;
}
