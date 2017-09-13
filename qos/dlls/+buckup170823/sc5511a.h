/*
 ***************************************************************************
 * USB functions for SignalCore Inc SC5511A products using "libusb"
 * functions and driver
 *
 * "libusb" license is covered by the LGPL 
 *	
 *	Copyright (c) 2013-2015 SignalCore Inc.
 *	
 * Rev 1.1
 *
 ****************************************************************************
 * SC5511A header file 
*/

#ifndef __SC5511A_H__
#define __SC5511A_H__

#include <D:\Dropbox\MATLAB GUI\USTC Measurement System\qes\qes\hardware\SC5511A\libusb.h>

//  Define USB SignalCore ID

#define SCI_USB_VID					0x277C  // SignalCore Vendor ID 
#define	SCI_USB_PID					0x001E  // Product ID SC5511A
#define SCI_SN_LENGTH				0x08	// SCI serial number length
#define SCI_PRODUCT_NAME			"SC5511A"

//  Define SignalCore USB endpoints
#define	SCI_ENDPOINT_IN_INT			0x81
#define	SCI_ENDPOINT_OUT_INT		0x02
#define	SCI_ENDPOINT_IN_BULK		0x83
#define	SCI_ENDPOINT_OUT_BULK		0x04

// 	Define for control endpoints
#define USB_ENDPOINT_IN				0x80
#define USB_ENDPOINT_OUT			0x00
#define USB_TYPE_VENDOR				(0x02 << 5)
#define USB_RECIP_INTERFACE			0x01


// Define error codes used 
#define SUCCESS							0
#define USBDEVICEERROR					-1
#define USBTRANSFERERROR				-2
#define INPUTNULL						-3
#define COMMERROR						-4
#define INPUTNOTALLOC					-5
#define EEPROMOUTBOUNDS					-6
#define INVALIDARGUMENT					-7
#define INPUTOUTOFRANGE					-8
#define NOREFWHENLOCK					-9
#define NORESOURCEFOUND					-10
#define INVALIDCOMMAND 					-11

// Define Config registers
#  define INITIALIZE						0x01	// init device
#  define SET_SYS_ACTIVE					0x02	// set the active led indicator on/off
#  define SYNTH_MODE						0x03	// set the synthesizer modes (harmonic, fractN, and loop gain)
#  define RF_MODE							0x04	// sets the RF Mode: Single, Sweep/list
#  define LIST_MODE_CONFIG					0x05    // Config the sweep/list behavior
#  define LIST_START_FREQ					0x06	// Set start frequency of sweep operation using start, stop and step
#  define LIST_STOP_FREQ					0x07	// Set the stop frequency of sweep operation using start, stop and step
#  define LIST_STEP_FREQ					0x08	// The step frequency size of sweep operation using start, stop and step
#  define LIST_DWELL_TIME					0x09	// The step time interval in 500 microseconds
#  define LIST_CYCLE_COUNT					0x0A    // number of cycles to run the sweep or list
#  define RESERVED0							0x0B	// Reserved for factory
#  define LIST_BUFFER_POINTS				0x0C	// number of points to step though in the list buffer
#  define LIST_BUFFER_WRITE					0x0D	// write the frequency to the list buffer in RAM
#  define LIST_BUF_MEM_XFER					0x0E    // transfer the list frequencies between RAM and EEPROM
#  define LIST_SOFT_TRIGGER					0x0F    // Soft trigger.

#  define RF_FREQUENCY						0x10	// sets the frequency of RF 1
#  define RF_LEVEL							0x11	// sets Power of RF1
#  define RF_ENABLE							0x12	// enable RF1 output
#  define RESERVED1							0x13    // reserved
#  define AUTO_LEVEL_DISABLE				0x14	// Disable leveling at frequency change
#  define RF_ALC_MODE						0x15	// close/open ACL
#  define RF_STANDBY						0x16	// sets RF1 into standby
#  define REFERENCE_MODE					0x17    // reference Settings
#  define REFERENCE_DAC_VALUE				0x18    // set reference DAC
#  define ALC_DAC_VALUE						0x19	// control the alc dacs
#  define RESERVED2							0x1A    // reserved
#  define STORE_DEFAULT_STATE				0x1B	// store the new default state
#  define RESERVED3							0x1C	// reserved
#  define RESERVED4							0x1D	// reserved
#  define RF2_STANDBY						0x1E	// Disables RF2 output and puts circuit into Standby
#  define RF2_FREQUENCY						0x1F	// sets RF2 frequency

//Query Registers
#  define GET_RF_PARAMETERS					0x20	// Get the sweep parameters such as rf_frequency, start_freq, stop_freq, ...etc
#  define GET_TEMPERATURE					0x21    // load sensor temperature into the SPI output buffer
#  define GET_DEVICE_STATUS					0x22    // load the board status into the SPI output buffer
#  define GET_DEVICE_INFO					0x23	// load the device info
#  define GET_LIST_BUFFER					0x24	// read the contents of the list buffer in RAM
#  define GET_ALC_DAC_VALUE					0x25    // get current ALC value
#  define GET_SERIAL_OUT_BUFFER				0x26	// SPI out buffer (not used in USB)

//System Registers
#  define SYNTH_SELF_CAL					0x47

// Note that all registers 0x27 to 0x50 are reserved for factory use. Writing to them accidentally may cause the 
// device to functionally fail.

#ifdef __cplusplus
extern "C"
{
#endif

#ifdef _LINUX 
	#define EXPORT_DLL 
#else
	#ifdef SC5511A_EXPORT  // Preprocessor
		#define EXPORT_DLL	__declspec(dllexport)
	#else
		#define EXPORT_DLL	__declspec(dllimport)
	#endif
#endif


//! define the USB session handle
typedef	struct
{
	libusb_device_handle *handle;	// libusb device handle
	libusb_context *ctx;			// session context
} sc5511a_device_handle_t;


typedef struct device_info_t
{
	unsigned int product_serial_number;
	float hardware_revision;
	float firmware_revision;
	struct date
	{
		unsigned char year; // year
		unsigned char month; 
		unsigned char day;
		unsigned char hour;
	} man_date;
} 	device_info_t;

typedef struct list_mode_t
{
	unsigned char sss_mode;				// 0 uses list for buffer, 1 calculates using stop-start-step	
	unsigned char sweep_dir;			// 0 start/beginning to stop/end, 1 stop/end to start/beginning
	unsigned char tri_waveform;			// 0 sawtooth, 1 triangular
	unsigned char hw_trigger;			// 0 soft trigger expected, 1 hard trigger expected
	unsigned char step_on_hw_trig;		// 0 trigger to sweep through list, 1 stepping on ever trigger (on hard trigger only)
	unsigned char return_to_start;		// if 1, frequency returns to start frequency after end of cycle(s)
	unsigned char trig_out_enable;		// 1 enable a trigger pulse at the trigger on pin
	unsigned char trig_out_on_cycle;	// 0 trigger out on every frequency change, 1 trigger on cycle complete
} list_mode_t;

typedef struct 
{
	unsigned char sum_pll_ld;			//lock status of main pll loop
	unsigned char crs_pll_ld;			//lock status of coarse offset pll loop (used only for harmonic mode)
	unsigned char fine_pll_ld;			//lock status of the dds tuned fine pll loop
	unsigned char crs_ref_pll_ld;		//lock status of the coarse reference pll loop
	unsigned char crs_aux_pll_ld;		//lock status of the auxiliary coarse pll loop (used only for IntN or FracN mode) 
	unsigned char ref_100_pll_ld;		//lock status of the 100 MHz VCXO pll loop
	unsigned char ref_10_pll_ld;		//lock status of the master 10 MHz TCXO pll loop
	unsigned char rf2_pll_ld;			//lock status of the chn#2 pll loop
} pll_status_t;

typedef struct 
{
	unsigned char rf1_lock_mode;		//synthesizer lock mode for chn#1: 0 = use harmonic circuit, 1 = fracN circuit
	unsigned char rf1_loop_gain;		//Changing the loop gain of the sum pll. 0 = normal, 1 = low. low gain helps suppress spurs and far out phase noise, but increase the close in phase.
	unsigned char device_access;		//if a seesion has been open for the device
	unsigned char rf2_standby;			//indicates chn#2 standby and output disable
	unsigned char rf1_standby;			//indicates chn#1 standby
	unsigned char auto_pwr_disable;		//indicates power adjustment is performed when frequency is changed.
	unsigned char alc_mode;				//indicates alc behavior: 0 is closed, 1 is opened 
	unsigned char rf1_out_enable;		//indicates chn#1 RF output
	unsigned char ext_ref_lock_enable;	//indicates that 100 MHz VCXO is set to lock to an external source
	unsigned char ext_ref_detect;		//indicates external source detected
	unsigned char ref_out_select;		//indicates the reference output select: 0=10 MHz, 1=100MHz
	unsigned char list_mode_running;	//indicates list/sweep is triggered and currently running 
	unsigned char rf1_mode;				//indicates chn#1 rf mode set: 0=fixed tone state, 1=list/sweep mode state
	unsigned char over_temp;			//indicates if the temperature of the devices has exceeded ~75degC internally
	unsigned char harmonic_ss;			//hamonic spur suppression state
} operate_status_t;

typedef struct 
{
	list_mode_t	list_mode;				//list mode parameters
	operate_status_t operate_status;			//operating parameters
	pll_status_t pll_status;			//pll status
} device_status_t;

typedef struct device_rf_params_t
{
	unsigned long long int rf1_freq;	//current ch#1 rf frequency 
	unsigned long long int start_freq;	//list start frequency 
	unsigned long long int stop_freq;	//list stop frequency ( > start_freq)
	unsigned long long int step_freq;	//list step frequency
	unsigned int sweep_dwell_time;		//dwell time at each frequency
	unsigned int sweep_cycles;			//number of cycle to sweep/list 
	unsigned int buffer_points;			//current number of list buffer points
	float rf_level;						//current ch#1 power level  
	unsigned short rf2_freq;			//current ch#2 rf frequency
} device_rf_params_t;

/* Export Function Prototypes */
/* sc5511a.c */

/* USB specific related functions */	

/*	Raw transferFunction not made public in documentation but useful to 
*	access factory only registers
*/
EXPORT_DLL int usb_transfer(sc5511a_device_handle_t *dev_handle, int size,
							unsigned char *buffer_out, 
							unsigned char *buffer_in);

/*	Function to find the serial numbers of all SignalCore device with the same product ID
	return:		The number of product devices found 
	output:		2-D array (or pointers) to pass out the list serial numbers for devices found
	Example, calling function could declare:
		char **serial_number_list;
		serial_number_list = (char**)malloc(sizeof(char*)*50); // 50 serial numbers
		for (i=0;i<50; i++)
			searchNumberList[i] = (char*)malloc(sizeof(char)*SCI_SN_LENGTH); 
	and pass searchNumberList into the function.
*/
EXPORT_DLL int sc5511a_search_devices(char **serial_number_list);

/* Function aimed to handle LabVIEW calls. As labView is not able to handle **pointers
*	*pointer to maximum of 20 devices are passed back
*/
EXPORT_DLL int sc5511a_search_devices_lv(char *serial_number_list);

/*	Function opens the target USB device.
	return:		pointer to usb_dev_handle type
	input: 		devSerialNum is the product serial number. Product number is available on
				the product label.
*/
EXPORT_DLL sc5511a_device_handle_t *sc5511a_open_device(char *dev_serial_num);

/*	Function opens the target USB device aimed to handle LabVIEW calls.
	return:		pointer to usb_dev_handle type
	input: 		devSerialNum is the product serial number. Product number is available on
				the product label.
*/
EXPORT_DLL sc5511a_device_handle_t *sc5511a_open_device_lv(char *dev_serial_num);

/*	Function  closes USB device associated with the handle.
	return:		error code
	input: 		usb device handle
*/
EXPORT_DLL int sc5511a_close_device(sc5511a_device_handle_t *dev_handle);
	

/* 	Register level access function prototypes 
	=========================================================================================
*/

/* 	Writing the register with via the USB device handle allocated by SC5511A_OpenDevice
	return: error code
	input: reg_byte contains the target register address, eg 0x10 is the frequency register
	input: 64 bit instruct_word contains necessary data for the specified register address
*/
EXPORT_DLL int sc5511a_reg_write(sc5511a_device_handle_t *dev_handle, 
							unsigned char reg_byte, 
							unsigned long long int instruct_word); 

/* 	Reading the register with via the USB device handle allocated by SC5511A_OpenDevice
	input: reg_byte contains the target register address, eg 0x10 is the frequency register
	input: 64 bit instruct_word contains necessary data for the specified register address
	output: 32 bit received_word is the return data request through the reg_byte and instruct_word
*/							
EXPORT_DLL int sc5511a_reg_read(sc5511a_device_handle_t *dev_handle, 
							unsigned char reg_byte, 
							unsigned long long int instruct_word,
							unsigned long long int *received_word);
							
/* 	Product configuration wrapper function prototypes 
	=========================================================================================
*/

/*	Sets the device frequency
	return: error code
	input:	frequency in Hz up to 20,000,000,000 Hz. If outside of this range, the return is OUTOFRANGE.
			Noted the frequency is tunable from ~80 MHz to ~20.5 GHz
*/
EXPORT_DLL int sc5511a_set_freq(sc5511a_device_handle_t *dev_handle, unsigned long long int freq);

/*	Sets the RF1 Synth pll mode. harmonic is best for phase noise
	return: error code
	input:	disable_spur_suppress: 0 auto switch to fracN mode to avoid harmonic mode spurs, 1 disables this behavior
			low_loop_gain: 0 normal loop gain, 1 low loop gain. Low loop gain generally gives better spur suppression 
			lock_mode: 0 = harmonic (default), 1=fractN
*/
EXPORT_DLL int sc5511a_set_synth_mode(sc5511a_device_handle_t *dev_handle, unsigned char disable_spur_suppress, unsigned char low_loop_gain, unsigned char lock_mode);

/*	Sets the rf Mode
	return: error code
	input:	rfMode: 0 = single tone, fixed, 1 = sweep/list
*/
EXPORT_DLL int sc5511a_set_rf_mode(sc5511a_device_handle_t *dev_handle, unsigned char rf_mode);

/*	Configures the list Mode behavior
	return: error code
	input:	Mode behavior see documentation for the data bit representation
*/
EXPORT_DLL int sc5511a_list_mode_config(sc5511a_device_handle_t *dev_handle, const list_mode_t *list_mode);

/*	Sets the sweep start frequency
	return: error code
	input:	frequency in Hz 25,000,000 to 6,000,000,000 Hz
*/
EXPORT_DLL int sc5511a_list_start_freq(sc5511a_device_handle_t *dev_handle, unsigned long long int freq);

/*	Sets the sweep stop frequency
	return: error code
	input:	frequency in Hz 25,000,000 to 6,000,000,000 Hz
*/
EXPORT_DLL int sc5511a_list_stop_freq(sc5511a_device_handle_t *dev_handle, unsigned long long int freq);

/*	Sets the sweep step frequency
	return: error code
	input:	frequency in Hz 25,000,000 to 6,000,000,000 Hz
*/
EXPORT_DLL int sc5511a_list_step_freq(sc5511a_device_handle_t *dev_handle, unsigned long long int freq);

/*	Sets the list/sweep dwell time
	return: error code
	input:	dwellTime in units of 500 us. 1 = 500us, 2 = 1 ms, etc
*/
EXPORT_DLL int sc5511a_list_dwell_time(sc5511a_device_handle_t *dev_handle, unsigned int dwell_time);

/*	Sets the cycle count
	return: error code
	input:	cycleCount 0 = loop sweep/list forever. 
*/
EXPORT_DLL int sc5511a_list_cycle_count(sc5511a_device_handle_t *dev_handle, unsigned int cycle_count);

/*	Sets the number of list points
	return: error code
	input:	list_points must be less or equal to the load buffer size
*/
EXPORT_DLL int sc5511a_list_buffer_points(sc5511a_device_handle_t *dev_handle, unsigned int list_points);

/*	Writes the frequency to the buffer list
	return: error code
	input:	freq in Hz 100,000,000 to 20,000,000,000 Hz. freq = 0 sets the buffer index back to 0, 
			0xFFFFFFFFFF terminates the buffer write squeence, number of buffer points is set. 
*/
EXPORT_DLL int sc5511a_list_buffer_write(sc5511a_device_handle_t *dev_handle, unsigned long long int freq);

/*	Transfers the list frequencies between RAM and EEPROM
	return: error code
	input:	transfer_mode = 0 will transfer the list in current RAM into the EEPROM, 1 = transfer from EEPROM to RAM
*/
EXPORT_DLL int sc5511a_list_buffer_transfer(sc5511a_device_handle_t *dev_handle, unsigned char transfer_mode);

/*	Sets the software trigger
	return: error code
	input:	none
*/
EXPORT_DLL int sc5511a_list_soft_trigger(sc5511a_device_handle_t *dev_handle);

/**	Sets the RF1 power level
	return: error code
	input: power level in dBm
*/
EXPORT_DLL int sc5511a_set_level(sc5511a_device_handle_t *dev_handle, float power_level);

/**	Enable RF1 output 
	return: error code
	input: enable
*/
EXPORT_DLL int sc5511a_set_output(sc5511a_device_handle_t *dev_handle, unsigned char enable);

/** enable/disable auto level on frequency change
	return: error code
	input: if enable the power level will be set to the previous level as frequency is changed
*/
EXPORT_DLL int sc5511a_set_auto_level_disable(sc5511a_device_handle_t *dev_handle, unsigned char disable);

/** set ALC mode
	return: error code
	input: 0 = close ALC loop amplitude adjustment, 1  = open loop amplitude adjustment
*/
EXPORT_DLL int sc5511a_set_alc_mode(sc5511a_device_handle_t *dev_handle, unsigned char mode);

/**	Puts the device circuitry for RF1 into power standby mode.
	return: error code
	input: enable			0:	Take device out off power standby. If the device was in standby,
								the device will be reprogrammed to the previous state. The device
								channel needs about a second to stabilize.
							1:	The device channel is taken into standby. All power to the channel 
								components are turned off. Conserves power consumption when not in use
*/
EXPORT_DLL int sc5511a_set_standby(sc5511a_device_handle_t *dev_handle, unsigned char enable);

/** set the reference clock behavior
	return: error code
	input:	lock_eternal: 1 locks the 100 MHz reference to the external 10 MHz source
			select_high:	1 exports 100 MHz instead of the default 10 MHz
*/
EXPORT_DLL int sc5511a_set_clock_reference(sc5511a_device_handle_t *dev_handle, unsigned char select_high, unsigned char lock_external);

/** manually adjust the internal reference clock dac to adjust for frequency accuracy
	return: error code
	input: dac value (max 0x3FFF)
*/
EXPORT_DLL int sc5511a_set_reference_dac(sc5511a_device_handle_t *dev_handle, unsigned short dac_value);

/** manually adjust the output alc dac to adjust the power level (if needed)
	return: error code
	input: dac value (max 0x3FFF)
*/
EXPORT_DLL int sc5511a_set_alc_dac(sc5511a_device_handle_t *dev_handle, unsigned short dac_value);

/**	Store the current state of the signal source into EEPROM as the default startup state
	return: error code
	input: 	none
*/										
EXPORT_DLL int sc5511a_store_default_state(sc5511a_device_handle_t *dev_handle);

/** enables RF2
	return: error code
	input: enable will put the channel into standby
*/
EXPORT_DLL int sc5511a_set_rf2_standby(sc5511a_device_handle_t *dev_handle, unsigned char enable);

/** set RF2 frequency (25 MHz steps in MHz)
	return: error code
	input: freq (25 to 3000) MHz
*/
EXPORT_DLL int sc5511a_set_rf2_freq(sc5511a_device_handle_t *dev_handle, unsigned short freq);

/**	Self Cal of the VCO dac values of the harmonic loop and sum loop
	return: error code
*/
EXPORT_DLL int sc5511a_synth_self_cal(sc5511a_device_handle_t *dev_handle);

/* Product Export Query (Read) function prototypes */
/*----------------------------------------------------------------------------------------------- */

/*	Function retrives the rf parameters such as rf1&2 frequencies and other rf sweep components 
	return:	error code
	output:	rf_parameters
*/
EXPORT_DLL int sc5511a_get_rf_parameters(sc5511a_device_handle_t *dev_handle, device_rf_params_t *device_rf_params);

/*	Function retrives current temperature of the device
	return:	error code
	output:	temperature 
*/
EXPORT_DLL int	sc5511a_get_temperature(sc5511a_device_handle_t *dev_handle, float *temp);

/*	Function retrives the device status - PLL locks status, ref clk config, etc see deviceStatus_t type
	return:	error code
	output:	device status
*/
EXPORT_DLL int sc5511a_get_device_status(sc5511a_device_handle_t *dev_handle, device_status_t *device_status);

/*	Function fetches the device Info
	return:	error code
	output:	deviceInfo		device information structure
*/
EXPORT_DLL int sc5511a_get_device_info(sc5511a_device_handle_t *dev_handle,
											device_info_t *deviceInfo);	

/*	Function retrives frequency member from the device list buffer.
	return:	error code
	input:	address is the address position of the buffer
	output:	frequency in Hz
*/
EXPORT_DLL int sc5511a_list_buffer_read(sc5511a_device_handle_t *dev_handle, unsigned int address, unsigned long long int *freq);

/*	Function retrives current alc dac value
	return:	error code
	output:	dac_value 
*/
EXPORT_DLL int	sc5511a_get_alc_dac(sc5511a_device_handle_t *dev_handle, unsigned short *dac_value);

											
# 	ifdef __cplusplus
}
#	endif

#	endif  /* __SC5511A__H__ */	