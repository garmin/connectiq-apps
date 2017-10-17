using Toybox.System as Sys;

//! The LogMonkey barrel provides some logging utilities to aid in
//! the development and debugging of Connect IQ apps. Information
//! can be logged to a certain log level via the available log levels.
//! The supported log levels are:
//!     - Debug: General debugging messages
//!     - Warn:  Warning messages about potential issues
//!     - Error: Errors that have occurred
module LogMonkey {

    // Create some static Logger variables which act as the APIs a
    // developer uses to log information to the different log levels.
    const Debug = new Logger("D", Sys);
    const Warn  = new Logger("W", Sys);
    const Error = new Logger("E", Sys);

}
