/**
 * Type definitions for Alarm Clock application
 */

export interface AlarmData {
  id: string;
  hour: number;
  minute: number;
  enabled: boolean;
  label: string;
  repeatDays: string[]; // Using string[] to match WeekDay enum values
  snoozeDuration: number;
  maxSnoozeCount: number;
  ringtoneUri: string;
  vibrationEnabled: boolean;
  volume: number;
  createdAt: string;
  updatedAt: string;
}

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType?: string;
}

export interface MigrationEventDetail {
  success: boolean;
  message: string;
  targetDevice?: DeviceInfo;
}

export interface AlarmDisplay {
  id: string;
  hour: number;
  minute: number;
  enabled: boolean;
  label: string;
  repeatDays: string[];
  nextAlarmTime: () => Date;
}