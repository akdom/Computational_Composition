// STK Flute
// patch
3 => int num_instr;
Flute flutes[num_instr];
PoleZero filters[num_instr];
JCRev reverb[num_instr];
int notes[num_instr][];

for (int i; i < num_instr; i++) {
	flutes[i] => filters[i] => reverb[i] => dac; 
}

flutes[0].clear( 1.0 );
0.000005 => flutes[0].jetDelay;
0.400000 => flutes[0].jetReflection;
0.000000 => flutes[0].endReflection;
0.000000 => flutes[0].noiseGain;
0.300000 => flutes[0].vibratoFreq;
0.100000 => flutes[0].vibratoGain;
0.800000 => flutes[0].pressure;
.25 => reverb[0].gain;
.05 => reverb[0].mix;
.99 => filter[0].blockZero;

flutes[1].clear( 1.0 );
0.001108 => flutes[1].jetDelay;
0.500000 => flutes[1].jetReflection;
0.000000 => flutes[1].endReflection;
0.000000 => flutes[1].noiseGain;
0.500000 => flutes[1].vibratoFreq;
0.100000 => flutes[1].vibratoGain;
0.800000 => flutes[1].pressure;
.25 => reverb[1].gain;
.05 => reverb[1].mix;
.99 => filter[1].blockZero;

// our notes
[ 57, 59, 60, 62, 64, 65, 67, 69 ] @=> notes[0][];
[ 57, 59, 60, 62, 64, 65, 67, 69 ] @=> notes[1][];

// infinite time-loop
while( true )
{
    // print
    <<< "---", "" >>>;

    for(notes[0].cap() - 1 => int i; i >= 0; i-- )
    {
        play( 12 + extract(i, notes[0]), 12+extract(i, notes[1]), 0.75 );
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
	
	Std.mtof( note1 ) => flute[0].freq; 
    Std.mtof( note2 ) => flute[1].freq;
    velocity => flute[0].noteOn;
    velocity => flute[1].noteOn;
	
	
	Std.rand2f(.25, 0.50) => float flute_gain;
	flute_gain => reverb[0].gain;
	0.75 - flute_gain => reverb[1].gain;
}
