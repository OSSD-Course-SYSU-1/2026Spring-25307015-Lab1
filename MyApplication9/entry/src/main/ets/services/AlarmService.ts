/**
 * Simplified Alarm Service
 * Basic alarm checking without background tasks or notifications
 */
import { Alarm, AlarmManager } from '../models/Alarm';

export class AlarmService {
  private static instance: AlarmService;
  private isRunning: boolean = false;
  private checkInterval: number = 60000; // Check every minute (60 seconds)
  private timerId: number = 0;

  private constructor() {}

  static getInstance(): AlarmService {
    if (!AlarmService.instance) {
      AlarmService.instance = new AlarmService();
    }
    return AlarmService.instance;
  }

  /**
   * Start the alarm service
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      console.info('Alarm service is already running');
      return;
    }

    try {
      // Start checking for alarms
      this.startAlarmCheck();
      
      this.isRunning = true;
      console.info('Alarm service started successfully');
    } catch (error) {
      console.error(`Failed to start alarm service: ${error}`);
      throw error;
    }
  }

  /**
   * Stop the alarm service
   */
  stop(): void {
    if (!this.isRunning) {
      return;
    }

    // Stop the timer
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }

    this.isRunning = false;
    console.info('Alarm service stopped');
  }

  /**
   * Start checking for alarms that need to be triggered
   */
  private startAlarmCheck(): void {
    // Clear any existing timer
    if (this.timerId) {
      clearInterval(this.timerId);
    }

    // Check immediately
    this.checkAndTriggerAlarms();

    // Set up periodic checking
    this.timerId = setInterval(() => {
      this.checkAndTriggerAlarms();
    }, this.checkInterval) as number;

    console.info('Alarm check started with interval:', this.checkInterval, 'ms');
  }

  /**
   * Check for alarms that need to be triggered and show notifications
   */
  private checkAndTriggerAlarms(): void {
    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const currentDay = now.getDay(); // 0 = Sunday, 1 = Monday, etc.
    
    const alarms = AlarmManager.alarms;
    const triggeredAlarms: Alarm[] = [];

    // Check each enabled alarm
    alarms.forEach(alarm => {
      if (!alarm.enabled) return;

      // Check if alarm should trigger now
      if (this.shouldTriggerAlarm(alarm, currentHour, currentMinute, currentDay)) {
        triggeredAlarms.push(alarm);
      }
    });

    // Show notifications for triggered alarms
    if (triggeredAlarms.length > 0) {
      this.showAlarmNotifications(triggeredAlarms);
    }
  }

  /**
   * Determine if an alarm should trigger at the given time
   */
  private shouldTriggerAlarm(alarm: Alarm, currentHour: number, currentMinute: number, currentDay: number): boolean {
    // Check time match
    if (alarm.hour !== currentHour || alarm.minute !== currentMinute) {
      return false;
    }

    // Check if alarm repeats today
    if (alarm.repeatDays.length > 0) {
      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const currentDayName = dayNames[currentDay];
      return alarm.repeatDays.includes(currentDayName as any);
    }

    // One-time alarm - check if it hasn't been triggered today
    // For simplicity, we'll trigger it every time it matches the time
    // In a real app, you would track when each alarm was last triggered
    return true;
  }

  /**
   * Show notifications for triggered alarms
   */
  private async showAlarmNotifications(alarms: Alarm[]): Promise<void> {
    for (const alarm of alarms) {
      await this.showAlarmNotification(alarm);
    }
  }

  /**
   * Show a notification for a single alarm
   */
  private async showAlarmNotification(alarm: Alarm): Promise<void> {
    try {
      const notificationId = Date.now();
      
      console.info(`Alarm triggered: ${alarm.label || 'Alarm'} at ${alarm.hour.toString().padStart(2, '0')}:${alarm.minute.toString().padStart(2, '0')}`);
      
      // In a real app, you would use the notification API here
      // For now, just log to console
      console.info(`[ALARM] ${alarm.label || 'Alarm'} - Time to wake up!`);
      
    } catch (error) {
      console.error('Failed to show alarm notification:', error);
    }
  }

  /**
   * Set check interval (for testing)
   */
  setCheckInterval(interval: number): void {
    this.checkInterval = interval;
    if (this.isRunning) {
      // Restart with new interval
      this.stop();
      this.start();
    }
  }

  /**
   * Check if service is running
   */
  isServiceRunning(): boolean {
    return this.isRunning;
  }
}