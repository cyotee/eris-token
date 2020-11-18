/** 
 * Currenlty deployed at
 * Mainnet: at0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce
 * Rinkerby: 0x92482Ba45A4D2186DafB486b322C6d0B88410FE7
*/
// TODO needs to be trimmed down and reimplemented into an interface.
pragma solidity 0.7.4;

interface IDateTime {

        function isLeapYear(uint16 year) public pure returns (bool);

        function leapYearsBefore(uint year) public pure returns (uint);

        function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12);

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime dt);

        function getYear(uint timestamp) public pure returns (uint16);

        function getMonth(uint timestamp) public pure returns (uint8);

        function getDay(uint timestamp) public pure returns (uint8);

        function getHour(uint timestamp) public pure returns (uint8);

        function getMinute(uint timestamp) public pure returns (uint8);

        function getSecond(uint timestamp) public pure returns (uint8);

        function getWeekday(uint timestamp) public pure returns (uint8);

        function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp);

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp);

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp);

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp);
}