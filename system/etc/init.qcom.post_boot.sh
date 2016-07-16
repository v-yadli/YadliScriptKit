#!/system/bin/sh
# Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# {{{ Prolog - hotplug, etc.
#
# enable adaptive LMK
# Yadli: TODO: adaptive LMK not supported by our kernel.
# echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
# echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk


target=`getprop ro.board.platform`
# Limit A57 max freq from msm_perf module in case CPU 4 is offline
echo "4:960000 5:960000 6:960000 7:960000" > /sys/module/msm_performance/parameters/cpu_max_freq
# disable thermal bcl hotplug to switch governor
echo 0 > /sys/module/msm_thermal/core_control/enabled
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
    echo -n disable > $mode
done
for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
do
    bcl_hotplug_mask=`cat $hotplug_mask`
    echo 0 > $hotplug_mask
done
for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
do
    bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
    echo 0 > $hotplug_soc_mask
done
for low_threshold_ua in /sys/devices/soc.0/qcom,bcl.*/low_threshold_ua
do
    echo "50000" > $low_threshold_ua
done
for high_threshold_ua in /sys/devices/soc.0/qcom,bcl.*/high_threshold_ua
do
    echo "4200000" > $high_threshold_ua
done
for vph_low_thresh_uv in /sys/devices/soc.0/qcom,bcl.*/vph_low_thresh_uv
do
    echo "3300000" > $vph_low_thresh_uv
done
for vph_high_thresh_uv in /sys/devices/soc.0/qcom,bcl.*/vph_high_thresh_uv
do
    echo "4300000" > $vph_high_thresh_uv
done

echo 25 > /sys/class/devfreq/qcom,cpubw.31/bw_hwmon/io_percent
echo 5 > /sys/class/kgsl/kgsl-3d0/default_pwrlevel
echo 50 > /sys/class/kgsl/kgsl-3d0/idle_timer
#}}}

# {{{Yadli: cpufreq: settings initial parameters and bounds

# LITTLE
for i in {0,1,2,3}
do
    chmod 644 /sys/devices/system/cpu/cpu$i/online
    echo 1 > /sys/devices/system/cpu/cpu$i/online
    chmod 444 /sys/devices/system/cpu/cpu$i/online
    chmod 644 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
    echo interactive > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
    chmod 444 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
    chmod 644 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
    echo 384000 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
    chmod 444 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
    chmod 644 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
    echo 1555200 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
done
# big
for i in {4,5,6,7}
do
    chmod 644 /sys/devices/system/cpu/cpu$i/online
    echo 1 > /sys/devices/system/cpu/cpu$i/online
    chmod 444 /sys/devices/system/cpu/cpu$i/online
    chmod 644 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
    echo interactive > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
    chmod 444 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
    chmod 644 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
    echo 384000 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
    chmod 444 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
    chmod 644 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
    echo 1958400 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
done

#}}}

# Yadli: at this point all 8 cores are operational. Setup governors
# before inserting core_ctl.

# LITTLE parameters, taken from DarkSpice on XperiaZ5
for i in {0,1,2,3}
do
    echo 200 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/go_hispeed_load
    echo 60000 768000:50000 960000:30000 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/above_hispeed_delay 
    echo 50000 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/timer_rate 
    echo 384000 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/hispeed_freq
    echo -1 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/timer_slack
    # Yadli: touch low freq target loads, to ease screen-off situation.
    echo 95 384000:75 460000:60 600000:75 672000:14 768000:80 864000:11 960000:98 1248000:8 1344000:99 1478000:100 1555200:100 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/target_loads
    echo 85000 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/min_sample_time
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/boost
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/align_windows
    echo 1 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/use_migration_notif
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/use_sched_load
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/max_freq_hysteresis
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/boostpulse_duration
done

# big
for i in {4,5,6,7}
do
    echo 200 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/go_hispeed_load
    echo "60000 1344000:50000 1632000:30000" > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/above_hispeed_delay
    echo 10000 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/timer_rate
    echo 384000 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/hispeed_freq
    echo 40000 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/timer_slack
    echo "97 480000:95 633000:80 768000:75 864000:65 960000:99 1248000:95 1344000:96 1440000:97 1536000:98 1632000:99 1728000:100 1824000:100" > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/target_loads
    echo 10000 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/min_sample_time
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/boost
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/align_windows
    echo 1 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/use_migration_notif
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/use_sched_load
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/max_freq_hysteresis
    echo 0 > /sys/devices/system/cpu/cpu$i/cpufreq/interactive/boostpulse_duration
done

# input boost configuration

echo 0:960000 1:960000 2:960000 3:960000 4:0 5:0 6:0 7:0 > /sys/module/cpu_boost/parameters/input_boost_freq
echo 0 > /sys/module/cpu_boost/parameters/boost_ms
echo 40 > /sys/module/cpu_boost/parameters/input_boost_ms

#{{{ Yadli: core_ctl module
# insert core_ctl module and use conservative paremeters
insmod /system/lib/modules/core_ctl.ko
echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
# re-enable thermal and BCL hotplug
echo 1 > /sys/module/msm_thermal/core_control/enabled
for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
do
    echo $bcl_hotplug_mask > $hotplug_mask
done
for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
do
    echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
done
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
    echo -n enable > $mode
done

# enable LPM
echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
# Restore CPU 4 max freq from msm_performance
echo "4:4294967295 5:4294967295 6:4294967295 7:4294967295" > /sys/module/msm_performance/parameters/cpu_max_freq

# Yadli: Little cluster
echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
echo 80 > /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
echo 50 > /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms
echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster
echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/task_thres
# Yadli: big cluster
echo 0 > /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
echo 0 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
echo 90 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
echo 50 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
echo 300 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres
#}}}


# {{{Yadli: Setting b.L scheduler parameters
echo 1 > /proc/sys/kernel/power_aware_timer_migration
echo 1 > /proc/sys/kernel/sched_migration_fixup
echo 30 > /proc/sys/kernel/sched_small_task
echo 80 > /proc/sys/kernel/sched_upmigrate
echo 20 > /proc/sys/kernel/sched_mostly_idle_load
echo 3 > /proc/sys/kernel/sched_mostly_idle_nr_run
echo 40 > /proc/sys/kernel/sched_downmigrate
echo 2 > /proc/sys/kernel/sched_window_stats_policy
echo 5 > /proc/sys/kernel/sched_ravg_hist_size
for i in cpu0 cpu1 cpu2 cpu3 cpu4 cpu5 cpu6 cpu7
do
    echo 20 > /sys/devices/system/cpu/$i/sched_mostly_idle_load
    echo 3 > /sys/devices/system/cpu/$i/sched_mostly_idle_nr_run
done
echo 400000 > /proc/sys/kernel/sched_freq_inc_notify
echo 400000 > /proc/sys/kernel/sched_freq_dec_notify
echo 1 > /proc/sys/kernel/sched_boost
#relax access permission for display power consumption
chown -h system /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
chown -h system /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
#enable rps static configuration
echo 8 >  /sys/class/net/rmnet_ipa0/queues/rx-0/rps_cpus
for devfreq_gov in /sys/class/devfreq/qcom,cpubw*/governor
do
    echo "bw_hwmon" > $devfreq_gov
    for cpu_io_percent in /sys/class/devfreq/qcom,cpubw*/bw_hwmon/io_percent
    do
        echo 20 > $cpu_io_percent
    done
    for cpu_guard_band in /sys/class/devfreq/qcom,cpubw*/bw_hwmon/guard_band_mbps
    do
        echo 30 > $cpu_guard_band
    done
done
for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
do
    echo "cpufreq" > $devfreq_gov
done
#}}}

#Yadli: GPU governor setting
# echo simple_ondemand > /sys/class/kgsl/kgsl-3d0/devfreq/governor

rm /data/system/perfd/default_values
setprop ro.min_freq_0 384000
setprop ro.min_freq_4 384000
start perfd

# Let kernel know our image version/variant/crm_version
image_version="10:"
image_version+=`getprop ro.build.id`
image_version+=":"
image_version+=`getprop ro.build.version.incremental`
image_variant=`getprop ro.product.name`
image_variant+="-"
image_variant+=`getprop ro.build.type`
oem_version=`getprop ro.build.version.codename`
echo 10 > /sys/devices/soc0/select_image
echo $image_version > /sys/devices/soc0/image_version
echo $image_variant > /sys/devices/soc0/image_variant
echo $oem_version > /sys/devices/soc0/image_crm_version

#Yadli: fire up nightshift.
/system/bin/nightshift &
#Yadli: fire up intelli-thermal
/system/bin/intellithermal &

# Enable QDSS agent if QDSS feature is enabled
# on a non-commercial build.  This allows QDSS
# debug tracing.
if [ -c /dev/coresight-stm ]; then
    build_variant=`getprop ro.build.type`
    if [ "$build_variant" != "user" ]; then
        # Test: Is agent present?
        if [ -f /data/qdss/qdss.agent.sh ]; then
            # Then tell agent we just booted
           /system/bin/sh /data/qdss/qdss.agent.sh on.boot &
        fi
    fi
fi

setenforce 0

# Start RIDL/LogKit II client
su -c /system/vendor/bin/startRIDL.sh &

# {{{Yadli: setprop tweaks
#
#Battery Tweaks

setprop pm.sleep_mode 1
setprop ro.ril.disable.power.collapse 0
setprop ro.ril.power_collapse 1
setprop ro.config.hw_power_saving 1
setprop ro.ril.fast.dormancy.rule 0
setprop ro.config.hw_fast_dormancy 1
setprop power_supply.wakeup enable
setprop power.saving.mode 1
setprop ro.config.hw_quickpoweron true

#Performance Tweaks

setprop ro.kernel.android.checkjni 0
setprop ro.kernel.checkjni 0
setprop debug.performance.tuning 1
setprop debug.enabletr true
setprop debug.overlayui.enable 1
setprop dalvik.vm.checkjni false
setprop dalvik.vm.verify-bytecode false
setprop dalvik.vm.jmiopts forcecopy
setprop dalvik.vm.dexopt-data-only 1

# }}}

# {{{Yadli: ZRAM

echo $((1024*1024*1024)) > /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon -p 10 /dev/block/zram0

# }}}
