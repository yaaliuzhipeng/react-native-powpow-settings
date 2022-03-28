import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';

import { addListener } from './PowpowSettings'


const App = (props) => {

	useEffect(() => {
		let subscription = addListener((event) => {
			console.log('旋转事件: ', event);
		})
		return () => {
			subscription.remove()
		}
	}, [])

	return (
		<View style={[styles.container]}>
			<Text>Hello </Text>
		</View>
	)
}
export default App

const styles = StyleSheet.create({
	container: {
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center'
	}
})