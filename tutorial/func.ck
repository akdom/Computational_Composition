SinOsc s => dac;
instrument(30, s);
instrument(100, s, 10, 1000);

fun void instrument( int frequency, SinOsc s)
{
	instrument(frequency, s, 30, 500);
}

fun void instrument( int frequency, SinOsc s, int lower, int upper)
{
	// connect sine oscillator to D/A convertor (sound card)
	frequency => s.freq;
	// loop in time
	while ( frequency < upper ) {
		// allow 100 milliseconds to pass
		1::ms => now;
		// Set frequency to random value in the range 30-1000
		//Std.rand2f(30.0, 1000.0) => s.freq;
		1 +=> frequency;
		frequency => s.freq;
	}

	100 +=> frequency;
	frequency => s.freq;
	200::ms => now;

	50 -=> frequency;
	frequency => s.freq;
	100::ms => now;

	50 -=> frequency;

	while ( frequency > lower ) {
		// allow 100 milliseconds to pass
		.5::ms => now;
		// Set frequency to random value in the range 30-1000
		//Std.rand2f(30.0, 1000.0) => s.freq;
		1 -=> frequency;
		frequency => s.freq;
	}
}
