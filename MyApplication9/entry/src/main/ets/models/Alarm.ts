/**
 * Alarm data model
 */
export class Alarm {
  id: string;
  hour: number; // 0-23
  minute: number; // 0-59
  enabled: boolean;
  label: string;
  repeatDays: WeekDay[]; // Days of week to repeat
  snoozeDuration: number; // minutes
  maxSnoozeCount: number;
  ringtoneUri: string;
  vibrationEnabled: boolean;
  volume: number; // 0-100
  createdAt: Date;
  updatedAt: Date;

  constructor(
    hour: number = 7,
    minute: number = 0,
    label: string = 'Alarm',
    repeatDays: WeekDay[] = [],
    enabled: boolean = true
  ) {
    this.id = this.generateId();
    this.hour = hour;
    this.minute = minute;
    this.enabled = enabled;
    this.label = label;
    this.repeatDays = repeatDays;
    this.snoozeDuration = 5; // default 5 minutes
    this.maxSnoozeCount = 3; // default 3 times
    this.ringtoneUri = 'system://alarm_default';
    this.vibrationEnabled = true;
    this.volume = 80;
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }

  private generateId(): string {
    return 'alarm_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }

  get timeString(): string {
    const hourStr = this.hour.toString().padStart(2, '0');
    const minuteStr = this.minute.toString().padStart(2, '0');
    return `${hourStr}:${minuteStr}`;
  }

  get nextAlarmTime(): Date {
    const now = new Date();
    const alarmTime = new Date();
    alarmTime.setHours(this.hour, this.minute, 0, 0);
    
    // If alarm time is earlier than now, set to tomorrow
    if (alarmTime <= now) {
      alarmTime.setDate(alarmTime.getDate() + 1);
    }
    
    // Handle repeat days
    if (this.repeatDays.length > 0) {
      const currentDay = now.getDay(); // 0 = Sunday, 1 = Monday, etc.
      const alarmDay = alarmTime.getDay();
      
      // Find the next repeating day
      const daysToAdd = this.findNextRepeatDay(currentDay);
      if (daysToAdd > 0) {
        alarmTime.setDate(alarmTime.getDate() + daysToAdd);
      }
    }
    
    return alarmTime;
  }

  private findNextRepeatDay(currentDay: number): number {
    if (this.repeatDays.length === 0) return 0;
    
    // Convert WeekDay enum to number (0-6)
    const repeatDayNumbers = this.repeatDays.map(day => 
      day === WeekDay.Sunday ? 0 :
      day === WeekDay.Monday ? 1 :
      day === WeekDay.Tuesday ? 2 :
      day === WeekDay.Wednesday ? 3 :
      day === WeekDay.Thursday ? 4 :
      day === WeekDay.Friday ? 5 : 6
    );
    
    // Sort days
    repeatDayNumbers.sort((a, b) => a - b);
    
    // Find next day
    for (const day of repeatDayNumbers) {
      if (day > currentDay) {
        return day - currentDay;
      }
    }
    
    // If no day found in current week, return days to first day of next week
    return (7 - currentDay) + repeatDayNumbers[0];
  }

  toObject(): Record<string, any> {
    return {
      id: this.id,
      hour: this.hour,
      minute: this.minute,
      enabled: this.enabled,
      label: this.label,
      repeatDays: this.repeatDays,
      snoozeDuration: this.snoozeDuration,
      maxSnoozeCount: this.maxSnoozeCount,
      ringtoneUri: this.ringtoneUri,
      vibrationEnabled: this.vibrationEnabled,
      volume: this.volume,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString()
    };
  }

  static fromObject(obj: Record<string, any>): Alarm {
    const alarm = new Alarm();
    alarm.id = obj.id || alarm.generateId();
    alarm.hour = obj.hour ?? 7;
    alarm.minute = obj.minute ?? 0;
    alarm.enabled = obj.enabled ?? true;
    alarm.label = obj.label || 'Alarm';
    alarm.repeatDays = obj.repeatDays || [];
    alarm.snoozeDuration = obj.snoozeDuration ?? 5;
    alarm.maxSnoozeCount = obj.maxSnoozeCount ?? 3;
    alarm.ringtoneUri = obj.ringtoneUri || 'system://alarm_default';
    alarm.vibrationEnabled = obj.vibrationEnabled ?? true;
    alarm.volume = obj.volume ?? 80;
    alarm.createdAt = obj.createdAt ? new Date(obj.createdAt) : new Date();
    alarm.updatedAt = obj.updatedAt ? new Date(obj.updatedAt) : new Date();
    return alarm;
  }
}

/**
 * Week days enum
 */
export enum WeekDay {
  Sunday = 'Sunday',
  Monday = 'Monday',
  Tuesday = 'Tuesday',
  Wednesday = 'Wednesday',
  Thursday = 'Thursday',
  Friday = 'Friday',
  Saturday = 'Saturday'
}

/**
 * Alarm state manager using in-memory storage
 */
export class AlarmManager {
  private static alarmsData: Record<string, any>[] = [];
  private static currentAlarmData: Record<string, any> | null = null;

  static init() {
    // Initialize with empty arrays if needed
    AlarmManager.alarmsData = [];
    AlarmManager.currentAlarmData = null;
  }

  static get alarms(): Alarm[] {
    return AlarmManager.alarmsData.map(data => Alarm.fromObject(data));
  }

  static set alarms(alarms: Alarm[]) {
    AlarmManager.alarmsData = alarms.map(alarm => alarm.toObject());
  }

  static get currentAlarm(): Alarm | null {
    return AlarmManager.currentAlarmData ? Alarm.fromObject(AlarmManager.currentAlarmData) : null;
  }

  static set currentAlarm(alarm: Alarm | null) {
    AlarmManager.currentAlarmData = alarm ? alarm.toObject() : null;
  }

  static addAlarm(alarm: Alarm): void {
    const alarms = AlarmManager.alarms;
    alarms.push(alarm);
    AlarmManager.alarms = alarms;
  }

  static updateAlarm(updatedAlarm: Alarm): void {
    const alarms = AlarmManager.alarms;
    const index = alarms.findIndex(a => a.id === updatedAlarm.id);
    if (index !== -1) {
      alarms[index] = updatedAlarm;
      AlarmManager.alarms = alarms;
    }
  }

  static deleteAlarm(alarmId: string): void {
    const alarms = AlarmManager.alarms.filter(a => a.id !== alarmId);
    AlarmManager.alarms = alarms;
  }

  static toggleAlarm(alarmId: string): void {
    const alarms = AlarmManager.alarms;
    const index = alarms.findIndex(a => a.id === alarmId);
    if (index !== -1) {
      alarms[index].enabled = !alarms[index].enabled;
      AlarmManager.alarms = alarms;
    }
  }

  static getAlarm(alarmId: string): Alarm | undefined {
    return AlarmManager.alarms.find(a => a.id === alarmId);
  }

  static getNextAlarm(): Alarm | null {
    const enabledAlarms = AlarmManager.alarms.filter(a => a.enabled);
    if (enabledAlarms.length === 0) return null;
    
    const now = new Date();
    let nextAlarm: Alarm | null = null;
    let nextTime: Date | null = null;
    
    for (const alarm of enabledAlarms) {
      const alarmTime = alarm.nextAlarmTime;
      if (!nextTime || alarmTime < nextTime) {
        nextTime = alarmTime;
        nextAlarm = alarm;
      }
    }
    
    return nextAlarm;
  }
}

/**
 * Breakpoint system for responsive design
 */
export enum Breakpoint {
  XS = 'xs',    // 0-320vp: wearables, extra small devices
  SM = 'sm',    // 320-600vp: phones
  MD = 'md',    // 600-840vp: unfolded foldables, tablets in portrait
  LG = 'lg',    // 840-1440vp: tablets in landscape, 2-in-1 devices
  XL = 'xl'     // 1440+vp: large screens
}

/**
 * Breakpoint manager for responsive layout
 */
import { mediaquery } from '@kit.ArkUI';

export class BreakpointManager {
  private static currentBreakpoint: Breakpoint = Breakpoint.SM;
  private static listeners: ((breakpoint: Breakpoint) => void)[] = [];

  static init() {
    // Initialize with default breakpoint
    this.updateBreakpoint();
    
    // Listen for screen size changes
    const smQuery = mediaquery.matchMediaSync('(320vp <= width < 600vp)');
    const mdQuery = mediaquery.matchMediaSync('(600vp <= width < 840vp)');
    const lgQuery = mediaquery.matchMediaSync('(840vp <= width < 1440vp)');
    const xlQuery = mediaquery.matchMediaSync('(width >= 1440vp)');

    smQuery.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.setBreakpoint(Breakpoint.SM);
      }
    });

    mdQuery.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.setBreakpoint(Breakpoint.MD);
      }
    });

    lgQuery.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.setBreakpoint(Breakpoint.LG);
      }
    });

    xlQuery.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.setBreakpoint(Breakpoint.XL);
      }
    });
  }

  private static updateBreakpoint() {
    // Get window width and determine breakpoint
    // This would typically use window.getWindowProperties() but for simplicity
    // we'll rely on media queries
  }

  private static setBreakpoint(breakpoint: Breakpoint) {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      this.notifyListeners();
    }
  }

  static getCurrentBreakpoint(): Breakpoint {
    return this.currentBreakpoint;
  }

  static addListener(listener: (breakpoint: Breakpoint) => void) {
    this.listeners.push(listener);
  }

  static removeListener(listener: (breakpoint: Breakpoint) => void) {
    const index = this.listeners.indexOf(listener);
    if (index !== -1) {
      this.listeners.splice(index, 1);
    }
  }

  private static notifyListeners() {
    this.listeners.forEach(listener => listener(this.currentBreakpoint));
  }

  static isMobile(): boolean {
    return this.currentBreakpoint === Breakpoint.SM || this.currentBreakpoint === Breakpoint.XS;
  }

  static isTablet(): boolean {
    return this.currentBreakpoint === Breakpoint.MD || this.currentBreakpoint === Breakpoint.LG;
  }

  static isLargeScreen(): boolean {
    return this.currentBreakpoint === Breakpoint.XL;
  }
}