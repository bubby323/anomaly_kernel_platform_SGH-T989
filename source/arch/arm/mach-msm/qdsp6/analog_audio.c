/* Copyright (c) 2010, Code Aurora Forum. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 and
 * only version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

#include <linux/init.h>
#include <linux/wait.h>
#include <linux/gpio.h>
#include <mach/pmic.h>
#include <mach/msm_qdsp6_audio.h>
#include <asm/string.h>
#include <asm/mach-types.h>
#include <mach/debug_mm.h>

#define GPIO_HEADSET_AMP 157
#define GPIO_SPEAKER_AMP 39
#define GPIO_HEADSET_SHDN_N 48

void analog_init(void)
{
	/* stereo pmic init */
	pmic_spkr_set_gain(LEFT_SPKR, SPKR_GAIN_PLUS12DB);
	pmic_spkr_set_gain(RIGHT_SPKR, SPKR_GAIN_PLUS12DB);
	pmic_mic_set_volt(MIC_VOLT_1_80V);

	if (machine_is_qsd8x50a_st1_5()) {
		gpio_set_value(GPIO_SPEAKER_AMP, 0);
		gpio_set_value(GPIO_HEADSET_SHDN_N, 0);
	} else {
		gpio_direction_output(GPIO_HEADSET_AMP, 1);
		gpio_set_value(GPIO_HEADSET_AMP, 0);
	}
}

void analog_headset_enable(int en)
{
	pr_debug("[%s:%s] en = %d\n", __MM_FILE__, __func__, en);
	/* enable audio amp */
	if (machine_is_qsd8x50a_st1_5())
		gpio_set_value(GPIO_HEADSET_SHDN_N, !!en);
	else
		gpio_set_value(GPIO_HEADSET_AMP, !!en);
}

void analog_speaker_enable(int en)
{
	struct spkr_config_mode scm;
	memset(&scm, 0, sizeof(scm));

	pr_debug("[%s:%s] en = %d\n", __MM_FILE__, __func__, en);
	if (en) {
		scm.is_right_chan_en = 1;
		scm.is_left_chan_en = 1;
		scm.is_stereo_en = 1;
		scm.is_hpf_en = 1;
		pmic_spkr_en_mute(LEFT_SPKR, 0);
		pmic_spkr_en_mute(RIGHT_SPKR, 0);
		pmic_set_spkr_configuration(&scm);
		pmic_spkr_en(LEFT_SPKR, 1);
		pmic_spkr_en(RIGHT_SPKR, 1);

		/* Enable Speaker Amplifier */
		if (machine_is_qsd8x50a_st1_5()) {
			pmic_secure_mpp_control_digital_output(
					PM_MPP_21, PM_MPP__DLOGIC__LVL_VDD,
					PM_MPP__DLOGIC_OUT__CTRL_HIGH);
			gpio_set_value(GPIO_SPEAKER_AMP, !!en);
		}
		
		/* unmute */
		pmic_spkr_en_mute(LEFT_SPKR, 1);
		pmic_spkr_en_mute(RIGHT_SPKR, 1);
	} else {
		pmic_spkr_en_mute(LEFT_SPKR, 0);
		pmic_spkr_en_mute(RIGHT_SPKR, 0);

		/* Disable Speaker Amplifier */
		if (machine_is_qsd8x50a_st1_5()) {
			gpio_set_value(GPIO_SPEAKER_AMP, !!en);
			pmic_secure_mpp_control_digital_output(
					PM_MPP_21, PM_MPP__DLOGIC__LVL_VDD,
					PM_MPP__DLOGIC_OUT__CTRL_LOW);
		}

		pmic_spkr_en(LEFT_SPKR, 0);
		pmic_spkr_en(RIGHT_SPKR, 0);

		pmic_set_spkr_configuration(&scm);
	}
}

void analog_mic_enable(int en)
{
	pr_debug("[%s:%s] en = %d\n", __MM_FILE__, __func__, en);
	pmic_mic_en(en);
}

static struct q6audio_analog_ops ops = {
	.init = analog_init,
	.speaker_enable = analog_speaker_enable,
	.headset_enable = analog_headset_enable,
	.int_mic_enable = analog_mic_enable,
	.ext_mic_enable = analog_mic_enable,
};

static int __init init(void)
{
	q6audio_register_analog_ops(&ops);
	return 0;
}

device_initcall(init);
