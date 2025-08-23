import styles from './styles.module.css';

export default function Availability({ modules = [] }) {

    const getAvailableModules = (plan, index) => {
        if (index === modules.length - 2) {
            return <div><strong>{plan}</strong> and </div>;
        }
        if (index === modules.length - 1) {
            return <div><strong>{plan}</strong>.</div>;
        }
        return <div><strong>{plan}</strong>,</div>;
    };

    const plansRow =
            <tr>
                <td className={styles.availablePlans}>
                    <div className={styles.availablePlansTitle}>Appies to: </div>
                    {
                        modules.map((planName, index) => (
                            <div className={styles.availablePlan}>
                                {
                                    getAvailableModules(planName, index)
                                }
                            </div>
                        ))
                    }
                </td>
            </tr>;

    return (
        <table className={styles.container}>
            <tbody>
                {plansRow}
            </tbody>
        </table>

    );
}
